class DeadlineCheckerJob < ApplicationJob
  queue_as :default

  def perform
    task_queue_manager = TaskQueueManager.instance

    Rails.logger.info "Checking task deadlines"

    overdue_count = task_queue_manager.check_deadlines

    Rails.logger.info "Deadline check completed: #{overdue_count} overdue tasks found"

    # Move failed tasks to dead letter queue
    dead_letter_count = task_queue_manager.move_failed_to_dead_letter

    Rails.logger.info "Moved #{dead_letter_count} tasks to dead letter queue"

    {
      overdue_tasks: overdue_count,
      dead_letter_moved: dead_letter_count
    }
  end
end
