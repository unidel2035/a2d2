class AgentTask < ApplicationRecord
  # JSON serialization for SQLite compatibility - Combined from both versions
  serialize :payload, coder: JSON
  serialize :result, coder: JSON
  serialize :metadata, coder: JSON
  serialize :input_data, coder: JSON
  serialize :output_data, coder: JSON
  serialize :dependencies, coder: JSON
  serialize :verification_details, coder: JSON
  serialize :execution_context, coder: JSON
  serialize :reviewed_by_agent_ids, coder: JSON

  # Associations - Phase 3
  belongs_to :agent, optional: true
  belongs_to :parent_task, class_name: 'AgentTask', optional: true
  has_many :child_tasks, class_name: 'AgentTask', foreign_key: 'parent_task_id', dependent: :nullify
  has_many :verification_logs, dependent: :destroy

  # Associations - Main branch
  has_many :llm_requests, dependent: :destroy
  has_many :agent_collaborations, dependent: :destroy
  has_many :orchestrator_events, dependent: :destroy

  # Validations
  validates :task_type, presence: true
  validates :status, presence: true, inclusion: {
    in: %w[pending assigned running completed failed dead_letter]
  }
  validates :priority, numericality: { only_integer: true }
  validates :retry_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :max_retries, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scopes - Combined
  scope :pending, -> { where(status: 'pending') }
  scope :assigned, -> { where(status: 'assigned') }
  scope :running, -> { where(status: 'running') }
  scope :completed, -> { where(status: 'completed') }
  scope :failed, -> { where(status: 'failed') }
  scope :dead_letter, -> { where(status: 'dead_letter') }
  scope :by_priority, -> { order(priority: :desc, created_at: :asc) }
  scope :ready_for_assignment, -> { pending.where('deadline IS NULL OR deadline > ?', Time.current) }
  scope :overdue, -> { where('deadline < ?', Time.current).where.not(status: %w[completed dead_letter]) }
  scope :ready_for_execution, -> { pending.where('dependencies IS NULL OR dependencies = ?', '[]') }
  scope :verified, -> { where(verification_status: 'passed') }
  scope :needs_verification, -> { completed.where(verification_status: ['pending', nil]) }
  scope :verification_failed, -> { where(verification_status: 'failed') }
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
      output_data: result_data,
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
    true
  end

  def move_to_dead_letter!
    update!(
      status: 'dead_letter',
      completed_at: Time.current
    )
    agent&.mark_idle!
    agent&.task_failed! if agent.present? && agent.respond_to?(:task_failed!)
  end

  # Status checks
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

  # Dependency management
  def dependencies_met?
    return true if dependencies.blank? || (dependencies.is_a?(Array) && dependencies.empty?)

    dependent_tasks = AgentTask.where(id: dependencies)
    dependent_tasks.all? { |t| t.status == 'completed' && (t.verification_status == 'passed' || t.verification_status.nil?) }
  end

  def dependent_tasks
    return AgentTask.none if dependencies.blank?
    AgentTask.where(id: dependencies)
  end

  # Verification methods
  def verify!(verifier_agent = nil)
    data_to_verify = output_data.presence || result.presence
    return false if data_to_verify.blank?

    # Basic verification - can be overridden for complex verification
    is_valid = data_to_verify.present? && error_message.blank?

    verification_result = {
      verified_at: Time.current,
      verifier_agent_id: verifier_agent&.id,
      checks_passed: is_valid,
      details: data_to_verify
    }

    update!(
      verification_status: is_valid ? 'passed' : 'failed',
      verification_details: verification_result,
      quality_score: is_valid ? 100.0 : 0.0
    ) if respond_to?(:verification_status)

    is_valid
  end

  def mark_verified!(score, details = {})
    return unless respond_to?(:verification_status)
    update!(
      verification_status: 'passed',
      quality_score: score,
      verification_details: details.merge(verified_at: Time.current)
    )
  end

  def mark_verification_failed!(reason)
    return unless respond_to?(:verification_status)
    update!(
      verification_status: 'failed',
      verification_details: { failed_at: Time.current, reason: reason }
    )
  end

  # Reviewer management
  def add_reviewer!(agent_id)
    return unless respond_to?(:reviewed_by_agent_ids)
    reviewers = reviewed_by_agent_ids || []
    reviewers << agent_id unless reviewers.include?(agent_id)
    update!(reviewed_by_agent_ids: reviewers)
  end

  def reviewing_agents
    return Agent.none unless respond_to?(:reviewed_by_agent_ids)
    return Agent.none if reviewed_by_agent_ids.blank?
    Agent.where(id: reviewed_by_agent_ids)
  end

  private

  def initialize_defaults
    self.payload ||= {}
    self.result ||= {}
    self.metadata ||= {}
    self.input_data ||= {}
    self.output_data ||= {}
    self.dependencies ||= []
  end
end
