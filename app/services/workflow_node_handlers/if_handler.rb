# frozen_string_literal: true

module WorkflowNodeHandlers
  # Handler for If/conditional nodes
  class IfHandler < BaseHandler
    def execute(input_data, parameters, execution_context)
      conditions = parameters['conditions'] || []
      condition_logic = parameters['conditionLogic'] || 'and'

      result = evaluate_conditions(input_data, conditions, condition_logic)

      {
        data: input_data,
        output: input_data,
        condition_result: result,
        branch: result ? 'true' : 'false'
      }
    end

    private

    def evaluate_conditions(data, conditions, logic)
      results = conditions.map do |condition|
        evaluate_single_condition(data, condition)
      end

      if logic == 'and'
        results.all?
      else # 'or'
        results.any?
      end
    end

    def evaluate_single_condition(data, condition)
      field = condition['field']
      operator = condition['operator']
      value = condition['value']

      data_value = safe_dig(data, field)

      case operator
      when 'equals', '='
        data_value == value
      when 'not_equals', '!='
        data_value != value
      when 'greater_than', '>'
        data_value.to_f > value.to_f
      when 'less_than', '<'
        data_value.to_f < value.to_f
      when 'contains'
        data_value.to_s.include?(value.to_s)
      when 'not_contains'
        !data_value.to_s.include?(value.to_s)
      when 'exists'
        !data_value.nil?
      when 'not_exists'
        data_value.nil?
      else
        false
      end
    end
  end
end
