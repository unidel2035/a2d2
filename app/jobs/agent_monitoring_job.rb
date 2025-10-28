class AgentMonitoringJob < ApplicationJob
  queue_as :default

  def perform
    orchestrator = Orchestrator.instance

    Rails.logger.info "Running agent monitoring"

    # Get monitoring stats
    stats = orchestrator.monitor_agents

    # Check for inactive agents
    Agent.recently_active.each do |agent|
      time_since_heartbeat = Time.current - agent.last_heartbeat

      if time_since_heartbeat > 5.minutes
        Rails.logger.warn "Agent #{agent.name} has not sent heartbeat for #{time_since_heartbeat.to_i} seconds"

        if time_since_heartbeat > 10.minutes
          orchestrator.handle_agent_failure(agent.id, reason: 'heartbeat_timeout')
        end
      end
    end

    # Schedule heartbeat checks for active agents
    Agent.active.find_each do |agent|
      AgentHeartbeatJob.perform_later(agent.id)
    end

    stats
  end
end
