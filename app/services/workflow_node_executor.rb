# frozen_string_literal: true

# WorkflowNodeExecutor handles execution of individual workflow nodes
# Routes to appropriate handler based on node type
class WorkflowNodeExecutor
  attr_reader :node

  def initialize(node)
    @node = node
  end

  # Execute the node with input data
  def execute(input_data, execution_context = {})
    handler = get_node_handler

    start_time = Time.current
    result = handler.execute(input_data, node.parameters, execution_context)
    end_time = Time.current

    {
      node_id: node.id,
      node_name: node.name,
      node_type: node.node_type,
      success: true,
      data: result[:data] || {},
      output: result[:output] || result[:data] || {},
      execution_time: end_time - start_time,
      executed_at: start_time
    }
  rescue StandardError => e
    {
      node_id: node.id,
      node_name: node.name,
      node_type: node.node_type,
      success: false,
      error: e.message,
      executed_at: Time.current
    }
  end

  private

  # Get the appropriate node handler based on node type
  def get_node_handler
    case node.node_type
    when 'trigger'
      WorkflowNodeHandlers::TriggerHandler.new
    when 'http_request', 'httpRequest'
      WorkflowNodeHandlers::HttpRequestHandler.new
    when 'set'
      WorkflowNodeHandlers::SetHandler.new
    when 'if'
      WorkflowNodeHandlers::IfHandler.new
    when 'switch'
      WorkflowNodeHandlers::SwitchHandler.new
    when 'merge'
      WorkflowNodeHandlers::MergeHandler.new
    when 'code'
      WorkflowNodeHandlers::CodeHandler.new
    when 'ai_agent'
      WorkflowNodeHandlers::AiAgentHandler.new
    when 'transform'
      WorkflowNodeHandlers::TransformHandler.new
    else
      # Default handler for unknown node types
      WorkflowNodeHandlers::DefaultHandler.new
    end
  end
end
