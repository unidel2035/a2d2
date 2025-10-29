# frozen_string_literal: true

module Orchestration
  # Task Queue Manager - Handles task prioritization, distribution, and retry logic
  # Implements patterns from hive-mind's task orchestration
  class TaskQueueManager
    class << self
      # Enqueue a new task
      def enqueue(task_type:, input_data:, priority: 5, deadline: nil, dependencies: [], metadata: {})
        task = AgentTask.create!(
          task_type: task_type,
          input_data: input_data,
          priority: priority,
          deadline_at: deadline,
          dependencies: dependencies,
          metadata: metadata,
          status: "pending",
          verification_status: "pending"
        )

        log_event(
          type: "task_enqueued",
          agent_task: task,
          severity: "info",
          message: "Task #{task.id} enqueued with priority #{priority}"
        )

        # Schedule task execution
        schedule_task(task)

        task
      end

      # Get next task to execute based on strategy
      def next_task(strategy: :priority_first)
        case strategy
        when :priority_first
          next_priority_task
        when :deadline_first
          next_deadline_task
        when :dependency_aware
          next_dependency_aware_task
        else
          next_priority_task
        end
      end

      # Assign task to an agent based on strategy
      def assign_task(task_id, strategy: :least_loaded)
        task = AgentTask.find(task_id)

        # Check if dependencies are met
        unless task.dependencies_met?
          log_event(
            type: "task_assignment_blocked",
            agent_task: task,
            severity: "warning",
            message: "Task #{task_id} blocked: dependencies not met"
          )
          return nil
        end

        agent = select_agent_for_task(task, strategy)

        unless agent
          log_event(
            type: "task_assignment_failed",
            agent_task: task,
            severity: "warning",
            message: "No available agent found for task #{task_id}"
          )
          return nil
        end

        task.update!(
          agent: agent,
          assigned_strategy: strategy.to_s
        )

        agent.task_started!

        log_event(
          type: "task_assigned",
          agent: agent,
          agent_task: task,
          severity: "info",
          message: "Task #{task_id} assigned to agent #{agent.name} using #{strategy} strategy"
        )

        { task: task, agent: agent }
      end

      # Retry failed tasks
      def retry_failed_tasks
        retryable_tasks = AgentTask.retryable

        results = retryable_tasks.map do |task|
          if task.retry!
            schedule_task(task)

            log_event(
              type: "task_retried",
              agent_task: task,
              severity: "info",
              message: "Task #{task.id} retry attempt #{task.retry_count}/#{task.max_retries}"
            )

            { task_id: task.id, retried: true }
          else
            { task_id: task.id, retried: false, reason: "max_retries_reached" }
          end
        end

        { retried_count: results.count { |r| r[:retried] }, details: results }
      end

      # Get queue statistics
      def queue_stats
        {
          pending: AgentTask.pending.count,
          processing: AgentTask.processing.count,
          completed: AgentTask.completed.count,
          failed: AgentTask.failed.count,
          overdue: AgentTask.overdue.count,
          ready_for_execution: AgentTask.ready_for_execution.count,
          needs_verification: AgentTask.needs_verification.count,
          verification_failed: AgentTask.verification_failed.count,
          by_priority: priority_distribution,
          average_wait_time: calculate_average_wait_time
        }
      end

      # Handle task timeout
      def handle_timeout(task_id)
        task = AgentTask.find(task_id)

        return if task.completed?

        task.fail!("Task execution timeout")

        log_event(
          type: "task_timeout",
          agent: task.agent,
          agent_task: task,
          severity: "error",
          message: "Task #{task_id} timed out"
        )

        # Try to retry if possible
        task.retry! if task.retry_count < task.max_retries
      end

      # Clean up old completed tasks
      def cleanup_old_tasks(older_than: 30.days.ago)
        old_tasks = AgentTask.completed.where("completed_at < ?", older_than)
        count = old_tasks.count
        old_tasks.destroy_all

        log_event(
          type: "tasks_cleaned_up",
          severity: "info",
          message: "Cleaned up #{count} old tasks"
        )

        { cleaned_count: count }
      end

      private

      # Task selection strategies
      def next_priority_task
        AgentTask.ready_for_execution.by_priority.first
      end

      def next_deadline_task
        AgentTask.ready_for_execution
          .where.not(deadline_at: nil)
          .order(deadline_at: :asc)
          .first || next_priority_task
      end

      def next_dependency_aware_task
        # Get tasks with no dependencies or all dependencies met
        ready_tasks = AgentTask.ready_for_execution.by_priority

        ready_tasks.find { |task| task.dependencies_met? }
      end

      # Agent selection strategies
      def select_agent_for_task(task, strategy)
        case strategy
        when :least_loaded
          select_least_loaded_agent(task)
        when :round_robin
          select_round_robin_agent(task)
        when :capability_match
          select_capability_matched_agent(task)
        when :high_performer
          select_high_performer_agent(task)
        else
          select_least_loaded_agent(task)
        end
      end

      def select_least_loaded_agent(task)
        Agent.least_loaded.find { |agent| agent.can_accept_task? && agent.can_handle?(task.task_type) }
      end

      def select_round_robin_agent(task)
        # Simple round-robin based on last assignment
        capable_agents = Agent.active.select { |a| a.can_accept_task? && a.can_handle?(task.task_type) }
        return nil if capable_agents.empty?

        # Get agent with oldest last assignment
        capable_agents.min_by { |a| a.agent_tasks.maximum(:created_at) || Time.at(0) }
      end

      def select_capability_matched_agent(task)
        # Find agent with best capability match
        Agent.active.select { |a| a.can_accept_task? && a.can_handle?(task.task_type) }
             .max_by { |a| calculate_capability_score(a, task) }
      end

      def select_high_performer_agent(task)
        # Select from high-performing agents
        Agent.high_performers
             .select { |a| a.can_accept_task? && a.can_handle?(task.task_type) }
             .min_by(&:load_score)
      end

      def calculate_capability_score(agent, task)
        # Score based on success rate, specialization, and past performance
        base_score = agent.success_rate || 50.0
        specialization_bonus = agent.specializes_in?(task.task_type) ? 20.0 : 0.0
        load_penalty = agent.load_score * 0.5

        base_score + specialization_bonus - load_penalty
      end

      # Helper methods
      def priority_distribution
        AgentTask.group(:priority).count
      end

      def calculate_average_wait_time
        completed_tasks = AgentTask.completed.where("started_at IS NOT NULL")
                                   .where("created_at >= ?", 24.hours.ago)

        return 0 if completed_tasks.empty?

        total_wait = completed_tasks.sum { |t| (t.started_at - t.created_at).to_i }
        (total_wait.to_f / completed_tasks.count).round(2)
      end

      def schedule_task(task)
        # Use Solid Queue to schedule task execution
        TaskExecutionJob.set(wait: task.scheduled_at || 0.seconds).perform_later(task.id)
      end

      def log_event(type:, agent: nil, agent_task: nil, severity: "info", message: nil, data: {})
        OrchestratorEvent.log(
          event_type: type,
          severity: severity,
          agent: agent,
          agent_task: agent_task,
          message: message,
          data: data
        )
      end
    end
  end
end
