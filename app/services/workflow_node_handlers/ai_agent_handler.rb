# frozen_string_literal: true

module WorkflowNodeHandlers
  # Handler for AI agent nodes - integrates with A2D2's agent system
  class AiAgentHandler < BaseHandler
    def execute(input_data, parameters, execution_context)
      agent_type = parameters['agentType'] || 'analyzer'
      task_description = evaluate_expression(parameters['task'], input_data)
      agent_config = parameters['config'] || {}

      # Find or create agent
      agent = find_agent(agent_type)

      unless agent
        return {
          data: { error: "Agent type '#{agent_type}' not found" },
          output: { error: "Agent type '#{agent_type}' not found" },
          error: "Agent type '#{agent_type}' not found"
        }
      end

      # Create agent task
      task = AgentTask.create!(
        agent: agent,
        description: task_description,
        input_data: input_data,
        status: 'pending'
      )

      # Execute task (synchronously for now, could be async)
      result = execute_agent_task(agent, task, agent_config)

      {
        data: result,
        output: result,
        agent_type: agent_type,
        task_id: task.id
      }
    rescue StandardError => e
      {
        data: { error: e.message },
        output: { error: e.message },
        error: e.message
      }
    end

    private

    def find_agent(agent_type)
      # Map n8n-style agent types to A2D2 agent types
      agent_class_map = {
        'analyzer' => 'Agents::AnalyzerAgent',
        'transformer' => 'Agents::TransformerAgent',
        'validator' => 'Agents::ValidatorAgent',
        'reporter' => 'Agents::ReporterAgent',
        'integration' => 'Agents::IntegrationAgent'
      }

      class_name = agent_class_map[agent_type]
      return nil unless class_name

      Agent.where(agent_type: agent_type, status: 'active').first ||
        Agent.create!(
          name: "#{agent_type.titleize} Agent",
          agent_type: agent_type,
          status: 'active',
          configuration: {}
        )
    end

    def execute_agent_task(agent, task, config)
      # Use A2D2's existing agent infrastructure
      case agent.agent_type
      when 'analyzer'
        analyze_data(task.input_data, config)
      when 'transformer'
        transform_data(task.input_data, config)
      when 'validator'
        validate_data(task.input_data, config)
      else
        task.input_data
      end
    end

    def analyze_data(data, config)
      # Simple analysis example
      {
        analyzed: true,
        input_size: data.to_json.size,
        fields: data.is_a?(Hash) ? data.keys : [],
        timestamp: Time.current
      }
    end

    def transform_data(data, config)
      # Simple transformation example
      transformations = config['transformations'] || []
      result = data.dup

      transformations.each do |transform|
        case transform['type']
        when 'rename_field'
          result[transform['to']] = result.delete(transform['from']) if result.is_a?(Hash)
        when 'add_field'
          result[transform['field']] = transform['value'] if result.is_a?(Hash)
        end
      end

      result
    end

    def validate_data(data, config)
      # Simple validation example
      rules = config['rules'] || []
      errors = []

      rules.each do |rule|
        field = rule['field']
        required = rule['required']

        if required && (!data.is_a?(Hash) || data[field].nil?)
          errors << "Field '#{field}' is required"
        end
      end

      {
        valid: errors.empty?,
        errors: errors,
        data: data
      }
    end
  end
end
