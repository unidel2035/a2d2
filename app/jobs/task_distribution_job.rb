class TaskDistributionJob < ApplicationJob
  queue_as :default

  def perform(task_id)
    task = AgentTask.find(task_id)

    unless task.pending?
      Rails.logger.debug "Task #{task_id} already assigned or processed"
      return
    end

    # Use orchestrator to distribute the task
    orchestrator = Orchestrator.instance
    success = orchestrator.distribute_task(task)

    unless success
      Rails.logger.warn "Failed to distribute task #{task_id}, will retry later"
      # Schedule retry in 30 seconds
      TaskDistributionJob.set(wait: 30.seconds).perform_later(task_id)
    end
  end
end
