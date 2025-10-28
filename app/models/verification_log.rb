class VerificationLog < ApplicationRecord
  # JSON serialization for SQLite compatibility
  serialize :verification_data, coder: JSON
  serialize :issues_found, coder: JSON

  # Associations
  belongs_to :agent_task
  belongs_to :agent, optional: true
  belongs_to :reassigned_to_task, class_name: 'AgentTask', optional: true

  # Validations
  validates :verification_type, presence: true, inclusion: {
    in: %w[schema business_rules data_quality completeness performance]
  }
  validates :status, presence: true, inclusion: { in: %w[passed failed warning] }
  validates :quality_score, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100
  }, allow_nil: true

  # Scopes
  scope :passed, -> { where(status: 'passed') }
  scope :failed, -> { where(status: 'failed') }
  scope :warning, -> { where(status: 'warning') }
  scope :low_quality, -> { where('quality_score < ?', 70) }
  scope :high_quality, -> { where('quality_score >= ?', 90) }
  scope :by_type, ->(type) { where(verification_type: type) }
  scope :recent, -> { where('created_at > ?', 24.hours.ago) }

  # Callbacks
  before_create :initialize_defaults

  # Quality assessment methods
  def needs_reassignment?
    failed? && quality_score.present? && quality_score < 50
  end

  def create_reassignment_task!
    return nil unless needs_reassignment?
    return reassigned_to_task if auto_reassigned?

    new_task = AgentTask.create!(
      task_type: agent_task.task_type,
      priority: agent_task.priority + 1,
      payload: agent_task.payload,
      metadata: agent_task.metadata.merge(
        reassigned_from: agent_task.id,
        reassignment_reason: 'low_quality_score'
      ),
      parent_task_id: agent_task.parent_task_id,
      required_capability: agent_task.required_capability
    )

    update!(
      auto_reassigned: true,
      reassigned_to_task: new_task
    )

    new_task
  end

  def passed?
    status == 'passed'
  end

  def failed?
    status == 'failed'
  end

  def warning?
    status == 'warning'
  end

  def high_quality?
    quality_score.present? && quality_score >= 90
  end

  def low_quality?
    quality_score.present? && quality_score < 70
  end

  def add_issue(issue_description, severity: 'medium')
    current_issues = issues_found.is_a?(Array) ? issues_found : []
    current_issues << {
      description: issue_description,
      severity: severity,
      detected_at: Time.current.iso8601
    }
    update!(issues_found: current_issues)
  end

  private

  def initialize_defaults
    self.verification_data ||= {}
    self.issues_found ||= []
  end
end
