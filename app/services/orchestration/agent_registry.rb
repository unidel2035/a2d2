# frozen_string_literal: true

module Orchestration
  # Agent Registry - Manages agent lifecycle, heartbeat monitoring, and capability tracking
  # Inspired by hive-mind's agent coordination patterns
  class AgentRegistry
    class << self
      # Register a new agent in the system
      def register(agent_type:, name:, capabilities: {}, specializations: [], config: {})
        agent = Agent.create!(
          name: name,
          type: agent_type,
          status: "idle",
          capabilities: capabilities,
          specialization_tags: specializations,
          configuration: config,
          last_heartbeat_at: Time.current,
          max_concurrent_tasks: config[:max_concurrent_tasks] || 5,
          heartbeat_interval: config[:heartbeat_interval] || 300
        )

        log_event(
          type: "agent_registered",
          agent: agent,
          severity: "info",
          message: "Agent #{name} registered successfully"
        )

        agent
      end

      # Update agent heartbeat
      def heartbeat(agent_id)
        agent = Agent.find(agent_id)
        agent.heartbeat!

        log_event(
          type: "agent_heartbeat",
          agent: agent,
          severity: "info",
          message: "Heartbeat received from #{agent.name}"
        )

        agent
      end

      # Mark agent as offline
      def mark_offline(agent_id)
        agent = Agent.find(agent_id)
        agent.update!(status: "offline")

        # Reassign pending tasks from this agent
        reassign_tasks_from_offline_agent(agent)

        log_event(
          type: "agent_offline",
          agent: agent,
          severity: "warning",
          message: "Agent #{agent.name} marked as offline"
        )

        agent
      end

      # Find agents that haven't sent heartbeat recently
      def find_stale_agents
        Agent.active.where("last_heartbeat_at < ?", 10.minutes.ago)
      end

      # Monitor and mark stale agents as offline
      def monitor_heartbeats
        stale_agents = find_stale_agents

        stale_agents.each do |agent|
          mark_offline(agent.id)

          log_event(
            type: "agent_heartbeat_timeout",
            agent: agent,
            severity: "error",
            message: "Agent #{agent.name} heartbeat timeout - marked offline"
          )
        end

        {
          checked_count: Agent.active.count,
          stale_count: stale_agents.count,
          stale_agent_ids: stale_agents.pluck(:id)
        }
      end

      # Get all active agents
      def active_agents
        Agent.active.order(created_at: :desc)
      end

      # Get agents by capability
      def agents_with_capability(capability)
        Agent.active.select { |agent| agent.can_handle?(capability) }
      end

      # Get agents by specialization
      def agents_with_specialization(specialization)
        Agent.active.select { |agent| agent.specializes_in?(specialization) }
      end

      # Get agent load distribution
      def load_distribution
        Agent.active.map do |agent|
          {
            id: agent.id,
            name: agent.name,
            type: agent.type,
            load_score: agent.load_score,
            current_tasks: agent.current_task_count,
            max_tasks: agent.max_concurrent_tasks,
            utilization: (agent.current_task_count.to_f / agent.max_concurrent_tasks * 100).round(2)
          }
        end.sort_by { |a| -a[:load_score] }
      end

      # Get system health status
      def system_health
        total_agents = Agent.count
        active = Agent.active.count
        idle = Agent.available.count
        busy = Agent.where(status: "busy").count
        offline = Agent.where(status: "offline").count

        {
          total_agents: total_agents,
          active: active,
          idle: idle,
          busy: busy,
          offline: offline,
          health_percentage: total_agents.zero? ? 0 : (active.to_f / total_agents * 100).round(2),
          load_distribution: load_distribution,
          recent_events: OrchestratorEvent.recent.limit(10).map do |e|
            { type: e.event_type, severity: e.severity, message: e.message, time: e.occurred_at }
          end
        }
      end

      # Get agent performance metrics
      def agent_performance(agent_id)
        agent = Agent.find(agent_id)

        {
          agent_id: agent.id,
          name: agent.name,
          type: agent.type,
          success_rate: agent.success_rate,
          total_completed: agent.total_tasks_completed,
          total_failed: agent.total_tasks_failed,
          average_completion_time: agent.average_completion_time,
          current_load: agent.load_score,
          specializations: agent.specializations,
          last_heartbeat: agent.last_heartbeat_at,
          status: agent.status
        }
      end

      private

      def reassign_tasks_from_offline_agent(agent)
        pending_tasks = agent.agent_tasks.processing

        pending_tasks.each do |task|
          task.update!(
            status: "pending",
            agent_id: nil,
            metadata: (task.metadata || {}).merge(
              reassigned_from: agent.id,
              reassigned_at: Time.current,
              reason: "agent_offline"
            )
          )

          log_event(
            type: "task_reassigned",
            agent: agent,
            agent_task: task,
            severity: "warning",
            message: "Task #{task.id} reassigned from offline agent"
          )
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
