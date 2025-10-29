# frozen_string_literal: true

module Orchestration
  # Main Orchestrator - Central coordinator for the agent hive
  # Implements the hive-mind pattern of multi-agent orchestration
  #
  # The Orchestrator manages:
  # - Agent lifecycle and health monitoring
  # - Task distribution and load balancing
  # - Quality verification
  # - Multi-agent collaboration
  # - System-wide coordination
  class Orchestrator
    class << self
      # Initialize the orchestration system
      def start
        log_event(
          type: "orchestrator_started",
          severity: "info",
          message: "Orchestrator started - initializing agent hive"
        )

        # Start monitoring jobs
        schedule_monitoring_jobs

        {
          status: "started",
          timestamp: Time.current,
          agents: AgentRegistry.system_health,
          tasks: TaskQueueManager.queue_stats
        }
      end

      # Process the task queue
      def process_queue(strategy: :least_loaded, batch_size: 10)
        processed = []
        batch_size.times do
          task = TaskQueueManager.next_task

          break unless task

          assignment = TaskQueueManager.assign_task(task.id, strategy: strategy)

          if assignment
            # Execute task
            result = execute_task(assignment[:task], assignment[:agent])
            processed << result
          end
        end

        log_event(
          type: "queue_processed",
          severity: "info",
          message: "Processed #{processed.count} tasks from queue"
        )

        { processed_count: processed.count, results: processed }
      end

      # Execute a single task
      def execute_task(task, agent)
        task.start!
        agent.update!(status: "busy")

        log_event(
          type: "task_execution_started",
          agent: agent,
          agent_task: task,
          severity: "info",
          message: "Agent #{agent.name} started executing task #{task.id}"
        )

        begin
          # Execute the task
          result = agent.execute(task)

          # Complete the task
          task.complete!(result)

          # Verify the result
          verification = VerificationLayer.verify_task(task.id)

          log_event(
            type: "task_execution_completed",
            agent: agent,
            agent_task: task,
            severity: "info",
            message: "Task #{task.id} completed successfully",
            data: { verification: verification }
          )

          { success: true, task_id: task.id, agent_id: agent.id, result: result, verification: verification }
        rescue StandardError => e
          task.fail!(e.message)

          log_event(
            type: "task_execution_failed",
            agent: agent,
            agent_task: task,
            severity: "error",
            message: "Task #{task.id} failed: #{e.message}"
          )

          { success: false, task_id: task.id, agent_id: agent.id, error: e.message }
        ensure
          # Update agent status
          agent.update!(status: agent.current_task_count.zero? ? "idle" : "busy")
        end
      end

      # Monitor system health
      def health_check
        agents_health = AgentRegistry.system_health
        queue_stats = TaskQueueManager.queue_stats
        recent_events = OrchestratorEvent.system_health(since: 1.hour.ago)

        overall_health = calculate_overall_health(agents_health, queue_stats, recent_events)

        {
          status: overall_health[:status],
          timestamp: Time.current,
          agents: agents_health,
          queue: queue_stats,
          events: recent_events,
          recommendations: overall_health[:recommendations]
        }
      end

      # Optimize system performance
      def optimize
        optimizations = []

        # Rebalance workload
        rebalance_result = rebalance_workload
        optimizations << rebalance_result if rebalance_result[:rebalanced] > 0

        # Retry failed tasks
        retry_result = TaskQueueManager.retry_failed_tasks
        optimizations << retry_result if retry_result[:retried_count] > 0

        # Monitor heartbeats
        heartbeat_result = AgentRegistry.monitor_heartbeats
        optimizations << heartbeat_result if heartbeat_result[:stale_count] > 0

        # Verify pending tasks
        verification_result = VerificationLayer.verify_pending_tasks
        optimizations << verification_result if verification_result[:total] > 0

        log_event(
          type: "system_optimized",
          severity: "info",
          message: "System optimization completed with #{optimizations.count} actions"
        )

        { optimizations: optimizations, timestamp: Time.current }
      end

      # Scale the agent pool
      def scale_agents(agent_type:, target_count:)
        current_count = Agent.where(type: agent_type).active.count

        if current_count < target_count
          # Scale up
          (target_count - current_count).times do |i|
            AgentRegistry.register(
              agent_type: agent_type,
              name: "#{agent_type.demodulize} ##{current_count + i + 1}",
              capabilities: default_capabilities_for(agent_type),
              specializations: []
            )
          end

          log_event(
            type: "agents_scaled_up",
            severity: "info",
            message: "Scaled up #{agent_type} agents from #{current_count} to #{target_count}"
          )
        elsif current_count > target_count
          # Scale down
          agents_to_remove = Agent.where(type: agent_type).available.limit(current_count - target_count)

          agents_to_remove.each do |agent|
            AgentRegistry.mark_offline(agent.id)
          end

          log_event(
            type: "agents_scaled_down",
            severity: "info",
            message: "Scaled down #{agent_type} agents from #{current_count} to #{target_count}"
          )
        end

        { previous_count: current_count, target_count: target_count, current_count: Agent.where(type: agent_type).active.count }
      end

      # Get orchestration statistics
      def statistics(since: 24.hours.ago)
        {
          timestamp: Time.current,
          period: since,
          agents: {
            total: Agent.count,
            active: Agent.active.count,
            average_success_rate: Agent.active.average(:success_rate)&.round(2) || 0,
            total_tasks_completed: Agent.sum(:total_tasks_completed),
            total_tasks_failed: Agent.sum(:total_tasks_failed)
          },
          tasks: {
            created: AgentTask.where("created_at >= ?", since).count,
            completed: AgentTask.completed.where("completed_at >= ?", since).count,
            failed: AgentTask.failed.where("completed_at >= ?", since).count,
            average_processing_time: calculate_average_processing_time(since)
          },
          collaborations: {
            total: AgentCollaboration.where("created_at >= ?", since).count,
            reviews: AgentCollaboration.where(collaboration_type: "review").where("created_at >= ?", since).count,
            consensus: AgentCollaboration.where(collaboration_type: "consensus").where("created_at >= ?", since).count
          },
          events: {
            total: OrchestratorEvent.where("occurred_at >= ?", since).count,
            by_severity: OrchestratorEvent.where("occurred_at >= ?", since).group(:severity).count
          }
        }
      end

      private

      def schedule_monitoring_jobs
        # Schedule periodic monitoring jobs using Solid Queue
        HeartbeatMonitorJob.set(wait: 5.minutes).perform_later
        TaskQueueProcessorJob.set(wait: 1.minute).perform_later
        SystemOptimizationJob.set(wait: 15.minutes).perform_later
      end

      def rebalance_workload
        overloaded_agents = Agent.active.where("load_score > ?", 80)
        rebalanced = 0

        overloaded_agents.each do |agent|
          # Find pending tasks for this agent
          pending_tasks = agent.agent_tasks.pending

          # Reassign to less loaded agents
          pending_tasks.each do |task|
            less_loaded_agent = Agent.least_loaded.where(type: agent.type).first

            if less_loaded_agent && less_loaded_agent.id != agent.id
              task.update!(agent: less_loaded_agent)
              rebalanced += 1
            end
          end
        end

        log_event(
          type: "workload_rebalanced",
          severity: "info",
          message: "Rebalanced #{rebalanced} tasks across agents"
        )

        { rebalanced: rebalanced }
      end

      def calculate_overall_health(agents_health, queue_stats, events)
        # Calculate health score
        agent_health_score = agents_health[:health_percentage] || 0
        queue_health_score = queue_stats[:pending] < 100 ? 100 : (100.0 / queue_stats[:pending] * 100)
        error_penalty = (events[:error_count] + events[:critical_count]) * 5

        overall_score = [(agent_health_score * 0.5 + queue_health_score * 0.5 - error_penalty), 0].max

        recommendations = []
        recommendations << "Scale up agents - too many pending tasks" if queue_stats[:pending] > 100
        recommendations << "Investigate critical errors" if events[:critical_count] > 0
        recommendations << "Some agents are offline - check heartbeats" if agents_health[:offline] > 0

        status = if overall_score >= 80
          "healthy"
        elsif overall_score >= 50
          "degraded"
        else
          "critical"
        end

        { status: status, score: overall_score.round(2), recommendations: recommendations }
      end

      def calculate_average_processing_time(since)
        completed = AgentTask.completed.where("completed_at >= ?", since)
        return 0 if completed.empty?

        times = completed.map(&:processing_time).compact
        return 0 if times.empty?

        (times.sum / times.size).round(2)
      end

      def default_capabilities_for(agent_type)
        case agent_type
        when "Agents::AnalyzerAgent"
          { statistical_analysis: true, anomaly_detection: true, data_profiling: true }
        when "Agents::ValidatorAgent"
          { data_validation: true, rule_checking: true, format_verification: true }
        when "Agents::TransformerAgent"
          { data_transformation: true, format_conversion: true, data_enrichment: true }
        when "Agents::ReporterAgent"
          { report_generation: true, visualization: true, pdf_export: true }
        when "Agents::IntegrationAgent"
          { api_integration: true, data_sync: true, webhook_handling: true }
        else
          {}
        end
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
