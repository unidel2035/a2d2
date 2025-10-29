# frozen_string_literal: true

# Workflow model representing n8n-style workflow automation
# Adapted from n8nDD workflow interfaces for Ruby/Rails
class Workflow < ApplicationRecord
  # Associations
  has_many :workflow_nodes, dependent: :destroy
  has_many :workflow_connections, dependent: :destroy
  has_many :workflow_executions, dependent: :destroy
  belongs_to :user, optional: true
  belongs_to :project, optional: true

  # Validations
  validates :name, presence: true
  validates :status, inclusion: { in: %w[active inactive error] }

  # Enums
  enum :status, {
    active: 'active',
    inactive: 'inactive',
    error: 'error'
  }, default: :inactive

  # Serialized attributes for complex data
  serialize :settings, coder: JSON
  serialize :static_data, coder: JSON
  serialize :tags, coder: JSON

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :inactive, -> { where(status: 'inactive') }

  # Instance methods

  # Execute the workflow
  def execute(input_data: {}, execution_mode: 'manual')
    execution = workflow_executions.create!(
      status: 'running',
      mode: execution_mode,
      started_at: Time.current,
      data: { input: input_data }
    )

    WorkflowExecutionJob.perform_later(execution.id)
    execution
  end

  # Validate workflow structure
  def valid_structure?
    return false if workflow_nodes.empty?

    # Check for at least one trigger node
    has_trigger = workflow_nodes.exists?(node_type: 'trigger')

    # Check all connections reference valid nodes
    valid_connections = workflow_connections.all? do |conn|
      workflow_nodes.exists?(id: conn.source_node_id) &&
        workflow_nodes.exists?(id: conn.target_node_id)
    end

    has_trigger && valid_connections
  end

  # Get workflow statistics
  def statistics
    {
      total_nodes: workflow_nodes.count,
      total_connections: workflow_connections.count,
      total_executions: workflow_executions.count,
      successful_executions: workflow_executions.where(status: 'success').count,
      failed_executions: workflow_executions.where(status: 'error').count,
      last_execution: workflow_executions.order(started_at: :desc).first&.started_at
    }
  end

  # Export workflow as JSON (n8n-compatible format)
  def to_n8n_format
    {
      id: id,
      name: name,
      nodes: workflow_nodes.map(&:to_n8n_format),
      connections: workflow_connections.map(&:to_n8n_format),
      active: status == 'active',
      settings: settings || {},
      staticData: static_data || {},
      tags: tags || [],
      createdAt: created_at,
      updatedAt: updated_at
    }
  end

  # Import workflow from n8n format
  def self.from_n8n_format(data, user: nil)
    transaction do
      workflow = create!(
        name: data[:name] || data['name'],
        status: (data[:active] || data['active']) ? 'active' : 'inactive',
        settings: data[:settings] || data['settings'] || {},
        static_data: data[:staticData] || data['staticData'] || {},
        tags: data[:tags] || data['tags'] || [],
        user: user
      )

      # Import nodes
      node_id_map = {}
      (data[:nodes] || data['nodes'] || []).each do |node_data|
        node = workflow.workflow_nodes.create!(
          name: node_data[:name] || node_data['name'],
          node_type: node_data[:type] || node_data['type'],
          type_version: node_data[:typeVersion] || node_data['typeVersion'] || 1,
          position: node_data[:position] || node_data['position'] || [0, 0],
          parameters: node_data[:parameters] || node_data['parameters'] || {},
          credentials: node_data[:credentials] || node_data['credentials'] || {}
        )
        old_id = node_data[:id] || node_data['id']
        node_id_map[old_id] = node.id if old_id
      end

      # Import connections
      (data[:connections] || data['connections'] || []).each do |conn_data|
        source_id = conn_data[:source] || conn_data['source']
        target_id = conn_data[:target] || conn_data['target']

        workflow.workflow_connections.create!(
          source_node_id: node_id_map[source_id] || source_id,
          target_node_id: node_id_map[target_id] || target_id,
          source_output_index: conn_data[:sourceOutputIndex] || conn_data['sourceOutputIndex'] || 0,
          target_input_index: conn_data[:targetInputIndex] || conn_data['targetInputIndex'] || 0,
          connection_type: conn_data[:type] || conn_data['type'] || 'main'
        )
      end

      workflow
    end
  end
end
