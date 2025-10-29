# frozen_string_literal: true

require 'test_helper'

class WorkflowTest < ActiveSupport::TestCase
  def setup
    @workflow = Workflow.new(
      name: 'Test Workflow',
      status: 'inactive'
    )
  end

  test 'should be valid with valid attributes' do
    assert @workflow.valid?
  end

  test 'should require name' do
    @workflow.name = nil
    assert_not @workflow.valid?
    assert_includes @workflow.errors[:name], "can't be blank"
  end

  test 'should have valid status' do
    @workflow.status = 'invalid_status'
    assert_not @workflow.valid?
  end

  test 'should create workflow from n8n format' do
    n8n_data = {
      name: 'Imported Workflow',
      active: true,
      nodes: [
        {
          name: 'Start',
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
          parameters: { url: 'https://example.com' }
        }
      ],
      connections: [
        {
          source: 0,
          target: 1,
          type: 'main'
        }
      ]
    }

    workflow = Workflow.from_n8n_format(n8n_data)

    assert workflow.persisted?
    assert_equal 'Imported Workflow', workflow.name
    assert_equal 'active', workflow.status
    assert_equal 2, workflow.workflow_nodes.count
    assert_equal 1, workflow.workflow_connections.count
  end

  test 'should export workflow to n8n format' do
    workflow = Workflow.create!(
      name: 'Export Test',
      status: 'active'
    )

    node = workflow.workflow_nodes.create!(
      name: 'Test Node',
      node_type: 'trigger',
      position: [100, 100],
      parameters: { test: 'value' }
    )

    n8n_format = workflow.to_n8n_format

    assert_equal 'Export Test', n8n_format[:name]
    assert_equal true, n8n_format[:active]
    assert_equal 1, n8n_format[:nodes].length
    assert_equal 'Test Node', n8n_format[:nodes].first[:name]
  end

  test 'should validate workflow structure' do
    workflow = Workflow.create!(name: 'Valid Structure')

    # Create trigger node
    trigger = workflow.workflow_nodes.create!(
      name: 'Trigger',
      node_type: 'trigger',
      position: [100, 100]
    )

    # Create action node
    action = workflow.workflow_nodes.create!(
      name: 'Action',
      node_type: 'action',
      position: [300, 100]
    )

    # Create connection
    workflow.workflow_connections.create!(
      source_node: trigger,
      target_node: action
    )

    assert workflow.valid_structure?
  end

  test 'should not be valid without trigger node' do
    workflow = Workflow.create!(name: 'No Trigger')

    workflow.workflow_nodes.create!(
      name: 'Action',
      node_type: 'action',
      position: [100, 100]
    )

    assert_not workflow.valid_structure?
  end

  test 'should get workflow statistics' do
    workflow = Workflow.create!(name: 'Stats Test')

    workflow.workflow_nodes.create!(
      name: 'Node 1',
      node_type: 'trigger',
      position: [100, 100]
    )

    workflow.workflow_executions.create!(
      status: 'success',
      started_at: Time.current
    )

    stats = workflow.statistics

    assert_equal 1, stats[:total_nodes]
    assert_equal 1, stats[:total_executions]
    assert_equal 1, stats[:successful_executions]
  end
end
