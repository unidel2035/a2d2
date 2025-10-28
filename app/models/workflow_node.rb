# frozen_string_literal: true

# WorkflowNode represents a single node in an n8n-style workflow
# Each node has a type (trigger, action, transform, etc.) and parameters
class WorkflowNode < ApplicationRecord
  # Associations
  belongs_to :workflow

  has_many :outgoing_connections,
           class_name: 'WorkflowConnection',
           foreign_key: 'source_node_id',
           dependent: :destroy

  has_many :incoming_connections,
           class_name: 'WorkflowConnection',
           foreign_key: 'target_node_id',
           dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :node_type, presence: true
  validates :type_version, numericality: { only_integer: true, greater_than: 0 }

  # Serialized attributes
  serialize :position, coder: JSON
  serialize :parameters, coder: JSON
  serialize :credentials, coder: JSON

  # Scopes
  scope :triggers, -> { where(node_type: 'trigger') }
  scope :actions, -> { where.not(node_type: 'trigger') }

  # Instance methods

  # Check if this is a trigger node
  def trigger?
    node_type == 'trigger'
  end

  # Get connected nodes
  def connected_nodes
    WorkflowNode.where(
      id: outgoing_connections.pluck(:target_node_id)
    )
  end

  # Get parent nodes
  def parent_nodes
    WorkflowNode.where(
      id: incoming_connections.pluck(:source_node_id)
    )
  end

  # Execute this node with given input data
  def execute(input_data, execution_context = {})
    # This will be implemented by specific node type handlers
    node_executor = WorkflowNodeExecutor.new(self)
    node_executor.execute(input_data, execution_context)
  end

  # Export node in n8n format
  def to_n8n_format
    {
      id: id.to_s,
      name: name,
      type: node_type,
      typeVersion: type_version,
      position: position || [0, 0],
      parameters: parameters || {},
      credentials: credentials || {}
    }
  end

  # Import node from n8n format
  def self.from_n8n_format(workflow, node_data)
    create!(
      workflow: workflow,
      name: node_data[:name] || node_data['name'],
      node_type: node_data[:type] || node_data['type'],
      type_version: node_data[:typeVersion] || node_data['typeVersion'] || 1,
      position: node_data[:position] || node_data['position'] || [0, 0],
      parameters: node_data[:parameters] || node_data['parameters'] || {},
      credentials: node_data[:credentials] || node_data['credentials'] || {}
    )
  end
end
