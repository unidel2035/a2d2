# frozen_string_literal: true

module WorkflowNodeHandlers
  # Handler for data transformation nodes
  class TransformHandler < BaseHandler
    def execute(input_data, parameters, execution_context)
      transformation_type = parameters['transformationType'] || 'map'
      operations = parameters['operations'] || []

      result = case transformation_type
               when 'map'
                 map_data(input_data, operations)
               when 'filter'
                 filter_data(input_data, operations)
               when 'reduce'
                 reduce_data(input_data, operations)
               else
                 input_data
               end

      {
        data: result,
        output: result,
        transformation_type: transformation_type
      }
    rescue StandardError => e
      {
        data: { error: e.message },
        output: { error: e.message },
        error: e.message
      }
    end

    private

    def map_data(data, operations)
      return data unless data.is_a?(Array) || data.is_a?(Hash)

      if data.is_a?(Array)
        data.map { |item| apply_operations(item, operations) }
      else
        apply_operations(data, operations)
      end
    end

    def filter_data(data, operations)
      return data unless data.is_a?(Array)

      data.select do |item|
        matches_conditions?(item, operations)
      end
    end

    def reduce_data(data, operations)
      return data unless data.is_a?(Array)

      data.reduce({}) do |result, item|
        operation = operations.first
        key = safe_dig(item, operation['key'])
        value = safe_dig(item, operation['value'])

        result[key] = value if key && value
        result
      end
    end

    def apply_operations(item, operations)
      result = {}

      operations.each do |operation|
        target_field = operation['targetField']
        source_field = operation['sourceField']
        value = operation['value']

        if source_field
          result[target_field] = safe_dig(item, source_field)
        elsif value
          result[target_field] = evaluate_expression(value, item)
        end
      end

      result
    end

    def matches_conditions?(item, conditions)
      conditions.all? do |condition|
        field = condition['field']
        operator = condition['operator']
        value = condition['value']

        item_value = safe_dig(item, field)

        case operator
        when 'equals', '='
          item_value == value
        when 'not_equals', '!='
          item_value != value
        when 'greater_than', '>'
          item_value.to_f > value.to_f
        when 'less_than', '<'
          item_value.to_f < value.to_f
        when 'contains'
          item_value.to_s.include?(value.to_s)
        else
          true
        end
      end
    end
  end
end
