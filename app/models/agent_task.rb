class AgentTask < ApplicationRecord
  belongs_to :agent, optional: true
  has_many :llm_requests, dependent: :destroy

  # Serialize JSON fields for SQLite compatibility
  serialize :input_data, coder: JSON
  serialize :output_data, coder: JSON
  serialize :metadata, coder: JSON

  # Validations
  validates :task_type, presence: true
  validates :status, inclusion: { in: %w[pending processing completed failed] }
  validates :priority, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }

  # Scopes
  scope :pending, -> { where(status: "pending") }
  scope :processing, -> { where(status: "processing") }
  scope :completed, -> { where(status: "completed") }
  scope :failed, -> { where(status: "failed") }
  scope :by_priority, -> { order(priority: :desc, created_at: :asc) }
  scope :overdue, -> { where("deadline_at < ?", Time.current).where.not(status: "completed") }

  # State transitions
  def start!
    update!(status: "processing", started_at: Time.current)
  end

  def complete!(output)
    update!(
      status: "completed",
      completed_at: Time.current,
      output_data: output
    )
  end

  def fail!(error)
    update!(
      status: "failed",
      completed_at: Time.current,
      error_message: error.to_s
    )
  end

  # Check if task is overdue
  def overdue?
    deadline_at && deadline_at < Time.current && status != "completed"
  end

  # Calculate processing time
  def processing_time
    return nil unless started_at && completed_at
    completed_at - started_at
  end
end
