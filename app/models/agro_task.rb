# AgroTask - Tasks executed by agricultural agents
class AgroTask < ApplicationRecord
  belongs_to :agro_agent

  TASK_TYPES = %w[
    data_collection
    analysis
    optimization
    coordination
    monitoring
    prediction
    validation
    execution
    reporting
  ].freeze

  PRIORITIES = %w[low normal high critical].freeze
  STATUSES = %w[pending in_progress completed failed].freeze

  validates :task_type, presence: true, inclusion: { in: TASK_TYPES }
  validates :priority, inclusion: { in: PRIORITIES }
  validates :status, inclusion: { in: STATUSES }

  serialize :input_data, coder: JSON
  serialize :output_data, coder: JSON

  scope :pending, -> { where(status: 'pending') }
  scope :in_progress, -> { where(status: 'in_progress') }
  scope :completed, -> { where(status: 'completed') }
  scope :failed, -> { where(status: 'failed') }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :high_priority, -> { where(priority: %w[high critical]) }

  # Start task execution
  def start!
    update(status: 'in_progress', started_at: Time.current)
  end

  # Complete task successfully
  def complete!(output = {})
    update(
      status: 'completed',
      completed_at: Time.current,
      output_data: output
    )
    agro_agent.increment!(:tasks_completed)
    agro_agent.update_success_rate
  end

  # Mark task as failed
  def fail!(error)
    update(
      status: 'failed',
      completed_at: Time.current,
      error_message: error.to_s
    )
    agro_agent.increment!(:tasks_failed)
    agro_agent.update_success_rate
  end

  # Check if task can be retried
  def can_retry?
    failed? && retry_count < 3
  end

  # Duration of task execution
  def duration
    return nil unless started_at && completed_at
    completed_at - started_at
  end
end
