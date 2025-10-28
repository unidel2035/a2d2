# frozen_string_literal: true

# Task Execution Job - Executes a single agent task
class TaskExecutionJob < ApplicationJob
  queue_as :default

  def perform(task_id)
    task = AgentTask.find(task_id)

    # Skip if task is already processing or completed
    return if task.status.in?(%w[processing completed])

    # Check if dependencies are met
    unless task.dependencies_met?
      # Reschedule for later
      TaskExecutionJob.set(wait: 5.minutes).perform_later(task_id)
      return
    end

    # Assign task to an agent
    assignment = Orchestration::TaskQueueManager.assign_task(task_id)

    return unless assignment

    # Execute the task
    Orchestration::Orchestrator.execute_task(assignment[:task], assignment[:agent])
  end
end
