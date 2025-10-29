class ProcessStepExecution < ApplicationRecord
  # Enums
  enum :status, {
    pending: 0,
    running: 1,
    completed: 2,
    failed: 3,
    skipped: 4
  }

  # Associations
  belongs_to :process_execution
  belongs_to :process_step

  # Validations
  validates :status, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :failed_steps, -> { where(status: :failed) }

  # Methods
  def duration
    return nil unless started_at

    end_time = completed_at || Time.current
    end_time - started_at
  end

  def retry!
    return unless failed?

    update!(
      status: :pending,
      error_message: nil,
      started_at: nil,
      completed_at: nil,
      retry_count: retry_count + 1
    )

    process_step.execute!(process_execution, input_data)
  end
end
