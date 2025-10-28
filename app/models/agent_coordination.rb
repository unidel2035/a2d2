# AgentCoordination - Multi-agent orchestration and coordination
class AgentCoordination < ApplicationRecord
  COORDINATION_TYPES = %w[
    workflow
    negotiation
    optimization
    collaboration
    resource_sharing
  ].freeze

  STATUSES = %w[active completed failed].freeze

  validates :coordination_type, presence: true, inclusion: { in: COORDINATION_TYPES }
  validates :status, inclusion: { in: STATUSES }

  serialize :participating_agents, coder: JSON
  serialize :coordination_data, coder: JSON

  scope :active, -> { where(status: 'active') }
  scope :by_type, ->(type) { where(coordination_type: type) }

  def agent_ids
    participating_agents || []
  end

  def agents
    AgroAgent.where(id: agent_ids)
  end

  def duration
    return nil unless started_at && completed_at
    completed_at - started_at
  end

  def data
    coordination_data || {}
  end
end
