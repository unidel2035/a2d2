# frozen_string_literal: true

module WorkflowNodeHandlers
  # Handler for Set node - sets/adds values to data
  class SetHandler < BaseHandler
    def execute(input_data, parameters, execution_context)
      values = parameters['values'] || []
      mode = parameters['mode'] || 'set'

      result = case mode
               when 'set'
                 set_values(input_data, values)
               when 'add'
                 add_values(input_data, values)
               when 'remove'
                 remove_values(input_data, values)
               else
                 input_data
               end

      {
        data: result,
        output: result
      }
    end

    private

    def set_values(data, values)
      result = data.is_a?(Hash) ? data.dup : {}

      values.each do |value_config|
        field = value_config['field'] || value_config['name']
        value = evaluate_expression(value_config['value'], data)

        result[field] = value
      end

      result
    end

    def add_values(data, values)
      result = data.is_a?(Hash) ? data.dup : {}

      values.each do |value_config|
        field = value_config['field'] || value_config['name']
        value = evaluate_expression(value_config['value'], data)

        result[field] = value unless result.key?(field)
      end

      result
    end

    def remove_values(data, values)
      result = data.is_a?(Hash) ? data.dup : {}

      values.each do |value_config|
        field = value_config['field'] || value_config['name']
        result.delete(field)
      end

      result
    end
  end
end
