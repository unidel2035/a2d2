# frozen_string_literal: true

# Task Queue Processor Job - Processes pending tasks from the queue
class TaskQueueProcessorJob < ApplicationJob
  queue_as :default

  def perform(strategy: :least_loaded, batch_size: 10)
    result = Orchestration::Orchestrator.process_queue(
      strategy: strategy,
      batch_size: batch_size
    )

    # Reschedule for next processing cycle
    TaskQueueProcessorJob.set(wait: 1.minute).perform_later

    result
  end
end
