# frozen_string_literal: true

# N8nIntegrationService provides integration with n8nDD-style workflows
# Enables A2D2 to import, export, and execute n8n-compatible workflows
class N8nIntegrationService
  attr_reader :workflow

  def initialize(workflow = nil)
    @workflow = workflow
  end

  # Import workflow from n8n JSON format
  def import_workflow(n8n_data, user: nil)
    Workflow.from_n8n_format(n8n_data, user: user)
  end

  # Export workflow to n8n JSON format
  def export_workflow(workflow_id)
    workflow = Workflow.find(workflow_id)
    workflow.to_n8n_format
  end

  # Validate n8n workflow structure
  def validate_n8n_workflow(n8n_data)
    errors = []

    # Check required fields
    errors << 'Missing workflow name' unless n8n_data[:name] || n8n_data['name']

    # Check nodes
    nodes = n8n_data[:nodes] || n8n_data['nodes']
    if nodes.nil? || nodes.empty?
      errors << 'Workflow must have at least one node'
    else
      # Validate each node
      nodes.each_with_index do |node, index|
        node_name = node[:name] || node['name']
        node_type = node[:type] || node['type']

        errors << "Node #{index}: Missing name" unless node_name
        errors << "Node #{index}: Missing type" unless node_type
      end
    end

    # Check connections
    connections = n8n_data[:connections] || n8n_data['connections']
    if connections && !connections.empty?
      node_ids = nodes.map { |n| n[:id] || n['id'] }.compact

      connections.each_with_index do |conn, index|
        source = conn[:source] || conn['source']
        target = conn[:target] || conn['target']

        errors << "Connection #{index}: Missing source" unless source
        errors << "Connection #{index}: Missing target" unless target
      end
    end

    {
      valid: errors.empty?,
      errors: errors
    }
  end

  # Sync workflow with external n8n instance
  def sync_with_n8n(n8n_url, api_key, workflow_id)
    # This would connect to an external n8n instance
    # For now, it's a placeholder for future implementation
    {
      success: false,
      message: 'External n8n sync not yet implemented',
      n8n_url: n8n_url
    }
  end

  # Convert A2D2 process to n8n workflow
  def convert_process_to_workflow(process_id)
    process = Process.find(process_id)

    workflow = Workflow.create!(
      name: "Converted: #{process.name}",
      status: 'inactive'
    )

    # Create trigger node
    trigger_node = workflow.workflow_nodes.create!(
      name: 'Manual Trigger',
      node_type: 'trigger',
      position: [100, 100],
      parameters: {
        triggerType: 'manual'
      }
    )

    previous_node = trigger_node

    # Convert process steps to workflow nodes
    process.process_steps.order(:step_number).each_with_index do |step, index|
      node = workflow.workflow_nodes.create!(
        name: step.name,
        node_type: map_step_type_to_node_type(step.step_type),
        position: [100 + (index + 1) * 200, 100],
        parameters: step.configuration || {}
      )

      # Create connection from previous node
      workflow.workflow_connections.create!(
        source_node: previous_node,
        target_node: node,
        connection_type: 'main'
      )

      previous_node = node
    end

    workflow
  end

  # Create workflow template
  def self.create_template(template_type)
    case template_type
    when 'simple_http'
      create_simple_http_template
    when 'ai_agent_pipeline'
      create_ai_agent_pipeline_template
    when 'data_transformation'
      create_data_transformation_template
    else
      raise ArgumentError, "Unknown template type: #{template_type}"
    end
  end

  private

  def map_step_type_to_node_type(step_type)
    {
      'manual' => 'manual',
      'automated' => 'action',
      'approval' => 'if',
      'notification' => 'notification',
      'data_processing' => 'transform'
    }[step_type] || 'action'
  end

  # Template: Simple HTTP request workflow
  def self.create_simple_http_template
    {
      name: 'Simple HTTP Request Template',
      nodes: [
        {
          name: 'Manual Trigger',
          type: 'trigger',
          typeVersion: 1,
          position: [100, 100],
          parameters: {}
        },
        {
          name: 'HTTP Request',
          type: 'http_request',
          typeVersion: 1,
          position: [300, 100],
          parameters: {
            url: 'https://api.example.com/data',
            method: 'GET',
            headers: {}
          }
        }
      ],
      connections: [
        {
          source: 0,
          target: 1,
          sourceOutputIndex: 0,
          targetInputIndex: 0,
          type: 'main'
        }
      ],
      active: false
    }
  end

  # Template: AI agent pipeline
  def self.create_ai_agent_pipeline_template
    {
      name: 'AI Agent Pipeline Template',
      nodes: [
        {
          name: 'Manual Trigger',
          type: 'trigger',
          typeVersion: 1,
          position: [100, 100],
          parameters: {}
        },
        {
          name: 'Analyze Data',
          type: 'ai_agent',
          typeVersion: 1,
          position: [300, 100],
          parameters: {
            agentType: 'analyzer',
            task: 'Analyze the input data'
          }
        },
        {
          name: 'Transform Results',
          type: 'ai_agent',
          typeVersion: 1,
          position: [500, 100],
          parameters: {
            agentType: 'transformer',
            task: 'Transform the analyzed data'
          }
        },
        {
          name: 'Validate Output',
          type: 'ai_agent',
          typeVersion: 1,
          position: [700, 100],
          parameters: {
            agentType: 'validator',
            task: 'Validate the transformed data'
          }
        }
      ],
      connections: [
        { source: 0, target: 1, sourceOutputIndex: 0, targetInputIndex: 0, type: 'main' },
        { source: 1, target: 2, sourceOutputIndex: 0, targetInputIndex: 0, type: 'main' },
        { source: 2, target: 3, sourceOutputIndex: 0, targetInputIndex: 0, type: 'main' }
      ],
      active: false
    }
  end

  # Template: Data transformation workflow
  def self.create_data_transformation_template
    {
      name: 'Data Transformation Template',
      nodes: [
        {
          name: 'Manual Trigger',
          type: 'trigger',
          typeVersion: 1,
          position: [100, 100],
          parameters: {}
        },
        {
          name: 'Filter Data',
          type: 'transform',
          typeVersion: 1,
          position: [300, 100],
          parameters: {
            transformationType: 'filter',
            operations: []
          }
        },
        {
          name: 'Map Fields',
          type: 'transform',
          typeVersion: 1,
          position: [500, 100],
          parameters: {
            transformationType: 'map',
            operations: []
          }
        },
        {
          name: 'Set Values',
          type: 'set',
          typeVersion: 1,
          position: [700, 100],
          parameters: {
            mode: 'set',
            values: []
          }
        }
      ],
      connections: [
        { source: 0, target: 1, sourceOutputIndex: 0, targetInputIndex: 0, type: 'main' },
        { source: 1, target: 2, sourceOutputIndex: 0, targetInputIndex: 0, type: 'main' },
        { source: 2, target: 3, sourceOutputIndex: 0, targetInputIndex: 0, type: 'main' }
      ],
      active: false
    }
  end
end
