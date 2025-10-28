# frozen_string_literal: true

module WorkflowNodeHandlers
  # Handler for Switch nodes - route data to different outputs
  class SwitchHandler < BaseHandler
    def execute(input_data, parameters, execution_context)
      rules = parameters['rules'] || []
      default_output = parameters['defaultOutput'] || 'fallback'

      selected_output = default_output

      rules.each_with_index do |rule, index|
        if evaluate_rule(input_data, rule)
          selected_output = rule['output'] || "output_#{index}"
          break
        end
      end

      {
        data: input_data,
        output: input_data,
        selected_output: selected_output
      }
    end

    private

    def evaluate_rule(data, rule)
      conditions = rule['conditions'] || []
      return false if conditions.empty?

      conditions.all? do |condition|
        evaluate_condition(data, condition)
      end
    end

    def evaluate_condition(data, condition)
      field = condition['field']
      operator = condition['operator']
      value = condition['value']

      data_value = safe_dig(data, field)

      case operator
      when 'equals'
        data_value == value
      when 'not_equals'
        data_value != value
      when 'greater_than'
        data_value.to_f > value.to_f
      when 'less_than'
        data_value.to_f < value.to_f
      when 'contains'
        data_value.to_s.include?(value.to_s)
      else
        false
      end
    end
  end
end
