class TaskQueueManager
  include Singleton

  # Create a new task
  def enqueue_task(task_type:, payload: {}, priority: 0, deadline: nil, required_capability: nil, metadata: {}, parent_task_id: nil)
    task = AgentTask.create!(
      task_type: task_type,
      payload: payload,
      priority: priority,
      deadline: deadline,
      required_capability: required_capability,
      metadata: metadata,
      parent_task_id: parent_task_id,
      status: 'pending'
    )

    Rails.logger.info "Task enqueued: #{task.id} (type: #{task_type}, priority: #{priority})"

    # Automatically distribute the task
    TaskDistributionJob.perform_later(task.id)

    task
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to enqueue task: #{e.message}"
    raise
  end

  # Batch task creation
  def enqueue_batch(tasks_data)
    tasks = tasks_data.map do |task_data|
      AgentTask.create!(
        task_type: task_data[:task_type],
        payload: task_data[:payload] || {},
        priority: task_data[:priority] || 0,
        deadline: task_data[:deadline],
        required_capability: task_data[:required_capability],
        metadata: task_data[:metadata] || {},
        parent_task_id: task_data[:parent_task_id],
        status: 'pending'
      )
    end

    # Distribute all tasks
    tasks.each do |task|
      TaskDistributionJob.perform_later(task.id)
    end

    Rails.logger.info "Batch enqueued: #{tasks.size} tasks"
    tasks
  end

  # Task prioritization
  def reprioritize_task(task_id, new_priority)
    task = AgentTask.find(task_id)

    unless task.pending?
      Rails.logger.warn "Cannot reprioritize task #{task_id}: not in pending status"
      return false
    end

    task.update!(priority: new_priority)
    Rails.logger.info "Task #{task_id} reprioritized to #{new_priority}"
    true
  end

  # Deadline management
  def check_deadlines
    overdue_tasks = AgentTask.overdue

    overdue_tasks.each do |task|
      Rails.logger.warn "Task #{task.id} is overdue (deadline: #{task.deadline})"

      # Increase priority for overdue tasks
      task.update!(priority: task.priority + 10)
    end

    overdue_tasks.count
  end

  # Dead letter queue management
  def process_dead_letter_queue
    dead_letter_tasks = AgentTask.dead_letter.order(created_at: :asc).limit(100)

    stats = {
      total: dead_letter_tasks.count,
      by_type: dead_letter_tasks.group(:task_type).count,
      oldest: dead_letter_tasks.first&.created_at
    }

    Rails.logger.info "Dead letter queue: #{stats.inspect}"
    stats
  end

  def retry_dead_letter_task(task_id)
    task = AgentTask.find(task_id)

    unless task.status == 'dead_letter'
      Rails.logger.warn "Task #{task_id} is not in dead letter queue"
      return false
    end

    task.update!(
      status: 'pending',
      retry_count: 0,
      error_message: nil,
      agent: nil
    )

    TaskDistributionJob.perform_later(task.id)
    Rails.logger.info "Dead letter task #{task_id} requeued for processing"
    true
  end

  # Dependency tracking
  def check_task_dependencies(task_id)
    task = AgentTask.find(task_id)

    return true unless task.parent_task_id

    parent = task.parent_task
    parent.completed?
  end

  def get_task_chain(task_id)
    task = AgentTask.find(task_id)
    chain = [task]

    current = task
    while current.parent_task_id
      current = current.parent_task
      chain.unshift(current)
    end

    chain
  end

  # Queue statistics
  def queue_statistics
    {
      total_tasks: AgentTask.count,
      pending: AgentTask.pending.count,
      assigned: AgentTask.assigned.count,
      running: AgentTask.running.count,
      completed: AgentTask.completed.count,
      failed: AgentTask.failed.count,
      dead_letter: AgentTask.dead_letter.count,
      by_priority: {
        high: AgentTask.where('priority >= ?', 10).count,
        medium: AgentTask.where('priority >= ? AND priority < ?', 5, 10).count,
        low: AgentTask.where('priority < ?', 5).count
      },
      overdue: AgentTask.overdue.count,
      avg_wait_time: calculate_average_wait_time,
      avg_processing_time: calculate_average_processing_time
    }
  end

  # Cleanup operations
  def cleanup_completed_tasks(older_than: 30.days.ago)
    count = AgentTask.completed.where('completed_at < ?', older_than).delete_all
    Rails.logger.info "Cleaned up #{count} completed tasks older than #{older_than}"
    count
  end

  def move_failed_to_dead_letter
    failed_tasks = AgentTask.failed.where('retry_count >= max_retries')

    failed_tasks.each do |task|
      task.move_to_dead_letter!
    end

    Rails.logger.info "Moved #{failed_tasks.count} failed tasks to dead letter queue"
    failed_tasks.count
  end

  private

  def calculate_average_wait_time
    pending_tasks = AgentTask.pending.where.not(created_at: nil)
    return 0 if pending_tasks.empty?

    total_wait = pending_tasks.sum { |task| Time.current - task.created_at }
    (total_wait / pending_tasks.count).round(2)
  end

  def calculate_average_processing_time
    completed = AgentTask.completed.where.not(started_at: nil, completed_at: nil)
    return 0 if completed.empty?

    total_time = completed.sum { |task| task.completed_at - task.started_at }
    (total_time / completed.count).round(2)
  end
end
