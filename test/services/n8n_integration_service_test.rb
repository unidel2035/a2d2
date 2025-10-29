# frozen_string_literal: true

require 'test_helper'

class N8nIntegrationServiceTest < ActiveSupport::TestCase
  def setup
    @service = N8nIntegrationService.new
  end

  test 'should validate valid n8n workflow' do
    workflow_data = {
      name: 'Valid Workflow',
      nodes: [
        {
          name: 'Start',
          type: 'trigger',
          parameters: {}
        }
      ],
      connections: []
    }

    result = @service.validate_n8n_workflow(workflow_data)

    assert result[:valid]
    assert_empty result[:errors]
  end

  test 'should detect missing workflow name' do
    workflow_data = {
      nodes: [
        {
          name: 'Start',
          type: 'trigger'
        }
      ]
    }

    result = @service.validate_n8n_workflow(workflow_data)

    assert_not result[:valid]
    assert_includes result[:errors], 'Missing workflow name'
  end

  test 'should detect missing nodes' do
    workflow_data = {
      name: 'No Nodes',
      nodes: []
    }

    result = @service.validate_n8n_workflow(workflow_data)

    assert_not result[:valid]
    assert_includes result[:errors], 'Workflow must have at least one node'
  end

  test 'should detect invalid nodes' do
    workflow_data = {
      name: 'Invalid Nodes',
      nodes: [
        {
          # Missing name and type
          parameters: {}
        }
      ]
    }

    result = @service.validate_n8n_workflow(workflow_data)

    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?('Missing name') }
    assert result[:errors].any? { |e| e.include?('Missing type') }
  end

  test 'should import workflow' do
    workflow_data = {
      name: 'Import Test',
      nodes: [
        {
          name: 'Start',
          type: 'trigger',
          typeVersion: 1,
          position: [100, 100],
          parameters: {}
        }
      ],
      connections: []
    }

    workflow = @service.import_workflow(workflow_data)

    assert workflow.persisted?
    assert_equal 'Import Test', workflow.name
    assert_equal 1, workflow.workflow_nodes.count
  end

  test 'should export workflow' do
    workflow = Workflow.create!(name: 'Export Test')
    workflow.workflow_nodes.create!(
      name: 'Node',
      node_type: 'trigger',
      position: [100, 100]
    )

    result = @service.export_workflow(workflow.id)

    assert_equal 'Export Test', result[:name]
    assert_equal 1, result[:nodes].length
  end

  test 'should create simple http template' do
    template = N8nIntegrationService.create_template('simple_http')

    assert_equal 'Simple HTTP Request Template', template[:name]
    assert_equal 2, template[:nodes].length
    assert_equal 1, template[:connections].length
    assert_equal 'trigger', template[:nodes].first[:type]
    assert_equal 'http_request', template[:nodes].last[:type]
  end

  test 'should create ai agent pipeline template' do
    template = N8nIntegrationService.create_template('ai_agent_pipeline')

    assert_equal 'AI Agent Pipeline Template', template[:name]
    assert_equal 4, template[:nodes].length
    assert_equal 3, template[:connections].length

    agent_nodes = template[:nodes].select { |n| n[:type] == 'ai_agent' }
    assert_equal 3, agent_nodes.length
  end

  test 'should create data transformation template' do
    template = N8nIntegrationService.create_template('data_transformation')

    assert_equal 'Data Transformation Template', template[:name]
    assert_equal 4, template[:nodes].length

    transform_nodes = template[:nodes].select { |n| n[:type] == 'transform' || n[:type] == 'set' }
    assert_equal 3, transform_nodes.length
  end

  test 'should raise error for unknown template' do
    assert_raises(ArgumentError) do
      N8nIntegrationService.create_template('unknown_template')
    end
  end
end
