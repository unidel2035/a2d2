class ProcessExecutionJob < ApplicationJob
  queue_as :default

  # PROC-003: Execution engine for processes
  def perform(process_execution_id)
    execution = ProcessExecution.find(process_execution_id)
    execution.execute!
  rescue StandardError => e
    Rails.logger.error "Process execution failed: #{e.message}"
    execution.update!(status: :failed, error_message: e.message) if execution
    raise
  end
end
