class AgentTask < ApplicationRecord
  belongs_to :agent, optional: true
  has_many :llm_requests, dependent: :destroy
  has_many :agent_collaborations, dependent: :destroy
  has_many :orchestrator_events, dependent: :destroy

  # Serialize JSON fields for SQLite compatibility
  serialize :input_data, coder: JSON
  serialize :output_data, coder: JSON
  serialize :metadata, coder: JSON
  serialize :dependencies, coder: JSON
  serialize :verification_details, coder: JSON
  serialize :execution_context, coder: JSON
  serialize :reviewed_by_agent_ids, coder: JSON

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
  scope :ready_for_execution, -> { pending.where(dependencies: nil).or(pending.where(dependencies: "[]")) }
  scope :verified, -> { where(verification_status: "passed") }
  scope :needs_verification, -> { completed.where(verification_status: ["pending", nil]) }
  scope :verification_failed, -> { where(verification_status: "failed") }
  scope :retryable, -> { failed.where("retry_count < max_retries") }

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
    agent&.task_failed! if agent.present?
  end

  # Retry task
  def retry!
    return false if retry_count >= max_retries

    increment!(:retry_count)
    update!(
      status: "pending",
      agent_id: nil,
      started_at: nil,
      completed_at: nil,
      error_message: nil
    )
    true
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

  # Check if task dependencies are met
  def dependencies_met?
    return true if dependencies.blank? || dependencies.empty?

    dependent_tasks = AgentTask.where(id: dependencies)
    dependent_tasks.all? { |t| t.status == "completed" && t.verification_status == "passed" }
  end

  # Verify task output
  def verify!(verifier_agent = nil)
    return false if output_data.blank?

    # Basic verification - can be overridden for complex verification
    is_valid = output_data.present? && error_message.blank?

    verification_result = {
      verified_at: Time.current,
      verifier_agent_id: verifier_agent&.id,
      checks_passed: is_valid,
      details: output_data
    }

    update!(
      verification_status: is_valid ? "passed" : "failed",
      verification_details: verification_result,
      quality_score: is_valid ? 100.0 : 0.0
    )

    is_valid
  end

  # Mark as verified with quality score
  def mark_verified!(score, details = {})
    update!(
      verification_status: "passed",
      quality_score: score,
      verification_details: details.merge(verified_at: Time.current)
    )
  end

  # Mark verification as failed
  def mark_verification_failed!(reason)
    update!(
      verification_status: "failed",
      verification_details: { failed_at: Time.current, reason: reason }
    )
  end

  # Get dependent tasks
  def dependent_tasks
    return AgentTask.none if dependencies.blank?
    AgentTask.where(id: dependencies)
  end

  # Add a reviewing agent
  def add_reviewer!(agent_id)
    reviewers = reviewed_by_agent_ids || []
    reviewers << agent_id unless reviewers.include?(agent_id)
    update!(reviewed_by_agent_ids: reviewers)
  end

  # Get reviewing agents
  def reviewing_agents
    return Agent.none if reviewed_by_agent_ids.blank?
    Agent.where(id: reviewed_by_agent_ids)
  end
end
