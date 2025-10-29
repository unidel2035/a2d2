# frozen_string_literal: true

# Heartbeat Monitor Job - Monitors agent heartbeats and marks stale agents as offline
class HeartbeatMonitorJob < ApplicationJob
  queue_as :default

  def perform
    result = Orchestration::AgentRegistry.monitor_heartbeats

    # Reschedule for next check
    HeartbeatMonitorJob.set(wait: 5.minutes).perform_later

    result
  end
end
