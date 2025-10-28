class AgentCollaboration < ApplicationRecord
  belongs_to :agent_task
  belongs_to :primary_agent, class_name: "Agent"

  # Serialize JSON fields
  serialize :participating_agent_ids, coder: JSON
  serialize :consensus_results, coder: JSON
  serialize :collaboration_metadata, coder: JSON

  # Validations
  validates :collaboration_type, inclusion: { in: %w[review consensus assistance] }
  validates :status, inclusion: { in: %w[pending in_progress completed failed] }

  # Scopes
  scope :pending, -> { where(status: "pending") }
  scope :in_progress, -> { where(status: "in_progress") }
  scope :completed, -> { where(status: "completed") }
  scope :by_type, ->(type) { where(collaboration_type: type) }

  # Get participating agents
  def participating_agents
    return [] unless participating_agent_ids.is_a?(Array)
    Agent.where(id: participating_agent_ids)
  end

  # Start collaboration
  def start!
    update!(status: "in_progress", started_at: Time.current)
  end

  # Complete collaboration
  def complete!(results)
    update!(
      status: "completed",
      completed_at: Time.current,
      consensus_results: results
    )
  end

  # Fail collaboration
  def fail!(error_message)
    update!(
      status: "failed",
      completed_at: Time.current,
      collaboration_metadata: (collaboration_metadata || {}).merge(error: error_message)
    )
  end

  # Calculate collaboration duration
  def duration
    return nil unless started_at && completed_at
    completed_at - started_at
  end
end
