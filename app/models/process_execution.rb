class ProcessExecution < ApplicationRecord
  # Enums
  enum status: {
    pending: 0,
    running: 1,
    completed: 2,
    failed: 3,
    cancelled: 4
  }

  # Associations
  belongs_to :process
  belongs_to :user, optional: true
  has_many :process_step_executions, dependent: :destroy

  # Validations
  validates :status, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :active, -> { where(status: [:pending, :running]) }
  scope :completed_recently, -> { where(status: :completed).where("completed_at >= ?", 24.hours.ago) }

  # Methods
  def execute!
    update!(status: :running, started_at: Time.current)

    begin
      steps = process.process_steps.ordered
      current_context = input_data

      steps.each do |step|
        result = step.execute!(self, current_context)
        current_context = current_context.merge(result)

        # PROC-004: Real-time monitoring
        broadcast_progress(step, result)
      end

      update!(
        status: :completed,
        completed_at: Time.current,
        output_data: current_context
      )
    rescue StandardError => e
      # PROC-005: Error handling and retry logic
      handle_error(e)
    end
  end

  def retry!
    return unless failed?

    update!(
      status: :pending,
      error_message: nil,
      started_at: nil,
      completed_at: nil
    )

    ProcessExecutionJob.perform_later(id)
  end

  def cancel!
    update!(status: :cancelled, completed_at: Time.current)
  end

  def duration
    return nil unless started_at

    end_time = completed_at || Time.current
    end_time - started_at
  end

  def progress_percentage
    return 0 if pending?
    return 100 if completed?

    total_steps = process.process_steps.count
    completed_steps = process_step_executions.where(status: :completed).count

    return 0 if total_steps.zero?

    (completed_steps.to_f / total_steps * 100).round(2)
  end

  private

  def broadcast_progress(step, result)
    # PROC-004: Real-time monitoring using Action Cable
    # ActionCable.server.broadcast("process_execution_#{id}", {
    #   step: step.name,
    #   progress: progress_percentage,
    #   result: result
    # })
  end

  def handle_error(error)
    update!(
      status: :failed,
      completed_at: Time.current,
      error_message: error.message
    )

    # Retry logic can be added here
    # retry! if should_retry?
  end
end
