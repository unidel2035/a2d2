# frozen_string_literal: true

# System Optimization Job - Performs periodic system optimization
class SystemOptimizationJob < ApplicationJob
  queue_as :default

  def perform
    result = Orchestration::Orchestrator.optimize

    # Reschedule for next optimization cycle
    SystemOptimizationJob.set(wait: 15.minutes).perform_later

    result
  end
end
