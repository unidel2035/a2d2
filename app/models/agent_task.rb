class AgentTask < ApplicationRecord
  # JSON serialization for SQLite compatibility
  serialize :payload, coder: JSON
  serialize :result, coder: JSON
  serialize :metadata, coder: JSON

  # Associations
  belongs_to :agent, optional: true
  belongs_to :parent_task, class_name: 'AgentTask', optional: true
  has_many :child_tasks, class_name: 'AgentTask', foreign_key: 'parent_task_id', dependent: :nullify
  has_many :verification_logs, dependent: :destroy

  # Validations
  validates :task_type, presence: true
  validates :status, presence: true, inclusion: {
    in: %w[pending assigned running completed failed dead_letter]
  }
  validates :priority, numericality: { only_integer: true }
  validates :retry_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :max_retries, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :assigned, -> { where(status: 'assigned') }
  scope :running, -> { where(status: 'running') }
  scope :completed, -> { where(status: 'completed') }
  scope :failed, -> { where(status: 'failed') }
  scope :dead_letter, -> { where(status: 'dead_letter') }
  scope :by_priority, -> { order(priority: :desc, created_at: :asc) }
  scope :ready_for_assignment, -> { pending.where('deadline IS NULL OR deadline > ?', Time.current) }
  scope :overdue, -> { where('deadline < ?', Time.current).where.not(status: %w[completed dead_letter]) }
  scope :retryable, -> { failed.where('retry_count < max_retries') }

  # Callbacks
  before_create :initialize_defaults

  # State machine methods
  def assign_to!(agent)
    return false unless pending?

    update!(
      agent: agent,
      status: 'assigned',
      started_at: Time.current
    )
  end

  def start!
    return false unless assigned?

    update!(status: 'running')
    agent&.mark_busy!
  end

  def complete!(result_data = {})
    return false unless running?

    update!(
      status: 'completed',
      result: result_data,
      completed_at: Time.current
    )
    agent&.mark_idle! if agent&.agent_tasks&.running&.where&.not(id: id)&.empty?
    agent&.update_health_score(5) if agent
  end

  def fail!(error_msg)
    update!(
      status: 'failed',
      error_message: error_msg,
      completed_at: Time.current
    )
    agent&.mark_idle!
    agent&.update_health_score(-10) if agent
  end

  def retry!
    return false unless failed?
    return false if retry_count >= max_retries

    increment!(:retry_count)
    update!(
      status: 'pending',
      agent: nil,
      started_at: nil,
      completed_at: nil,
      error_message: nil
    )
  end

  def move_to_dead_letter!
    update!(
      status: 'dead_letter',
      completed_at: Time.current
    )
    agent&.mark_idle!
  end

  def pending?
    status == 'pending'
  end

  def assigned?
    status == 'assigned'
  end

  def running?
    status == 'running'
  end

  def completed?
    status == 'completed'
  end

  def failed?
    status == 'failed'
  end

  def can_retry?
    failed? && retry_count < max_retries
  end

  def overdue?
    deadline.present? && deadline < Time.current && !completed?
  end

  def duration
    return nil unless started_at && completed_at
    completed_at - started_at
  end

  private

  def initialize_defaults
    self.payload ||= {}
    self.result ||= {}
    self.metadata ||= {}
  end
end
