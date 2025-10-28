# frozen_string_literal: true

# WorkflowExecutor handles the execution of a workflow
# Inspired by n8n's workflow execution engine
class WorkflowExecutor
  attr_reader :workflow, :execution

  def initialize(workflow, execution)
    @workflow = workflow
    @execution = execution
    @execution_data = {}
    @node_results = {}
  end

  # Execute the workflow
  def execute
    validate_workflow!

    # Get trigger nodes (entry points)
    trigger_nodes = workflow.workflow_nodes.triggers

    if trigger_nodes.empty?
      return { success: false, error: 'No trigger nodes found in workflow' }
    end

    # Start execution from each trigger node
    trigger_nodes.each do |trigger_node|
      execute_node(trigger_node, execution.data&.dig('input') || {})
    end

    {
      success: true,
      output: @node_results,
      execution_data: @execution_data
    }
  rescue StandardError => e
    {
      success: false,
      error: e.message,
      execution_data: @execution_data
    }
  end

  private

  # Validate workflow structure
  def validate_workflow!
    raise 'Workflow has no nodes' if workflow.workflow_nodes.empty?
    raise 'Invalid workflow structure' unless workflow.valid_structure?
  end

  # Execute a single node
  def execute_node(node, input_data, depth = 0)
    # Prevent infinite loops
    raise 'Maximum execution depth exceeded' if depth > 100

    # Check if node already executed
    return @node_results[node.id] if @node_results.key?(node.id)

    # Execute the node
    node_executor = WorkflowNodeExecutor.new(node)
    result = node_executor.execute(input_data, execution_context)

    # Store result
    @node_results[node.id] = result
    @execution_data[node.name] = result

    # Execute connected nodes with the output data
    node.outgoing_connections.each do |connection|
      target_node = connection.target_node
      execute_node(target_node, result[:output] || result[:data] || {}, depth + 1)
    end

    result
  end

  # Build execution context
  def execution_context
    {
      workflow_id: workflow.id,
      execution_id: execution.id,
      mode: execution.mode,
      started_at: execution.started_at,
      node_results: @node_results
    }
  end
end
