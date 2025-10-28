# frozen_string_literal: true

# WorkflowExecutionJob handles asynchronous execution of workflows
# Inspired by n8n's workflow execution engine
class WorkflowExecutionJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 5.seconds, attempts: 3

  def perform(execution_id)
    execution = WorkflowExecution.find(execution_id)
    workflow = execution.workflow

    return if execution.completed?

    execution.start!

    # Execute the workflow using the execution service
    executor = WorkflowExecutor.new(workflow, execution)
    result = executor.execute

    if result[:success]
      execution.complete!(result[:output])
    else
      execution.fail!(result[:error])
    end
  rescue StandardError => e
    execution = WorkflowExecution.find(execution_id)
    execution.fail!("Job execution failed: #{e.message}")
    raise e
  end
end
