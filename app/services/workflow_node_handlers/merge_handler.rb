# frozen_string_literal: true

module WorkflowNodeHandlers
  # Handler for Merge nodes - combines data from multiple inputs
  class MergeHandler < BaseHandler
    def execute(input_data, parameters, execution_context)
      mode = parameters['mode'] || 'combine'
      merge_strategy = parameters['mergeStrategy'] || 'append'

      # In a real implementation, this would receive data from multiple inputs
      # For now, we'll work with the input data as is
      result = case mode
               when 'combine'
                 combine_data(input_data, merge_strategy)
               when 'append'
                 append_data(input_data)
               when 'multiplex'
                 multiplex_data(input_data)
               else
                 input_data
               end

      {
        data: result,
        output: result,
        merge_mode: mode
      }
    end

    private

    def combine_data(data, strategy)
      case strategy
      when 'merge'
        # Merge objects or arrays
        if data.is_a?(Array) && data.all? { |item| item.is_a?(Hash) }
          data.reduce({}) { |merged, item| merged.merge(item) }
        else
          data
        end
      when 'append'
        # Keep as array
        data.is_a?(Array) ? data : [data]
      else
        data
      end
    end

    def append_data(data)
      data.is_a?(Array) ? data : [data]
    end

    def multiplex_data(data)
      # Create separate outputs for each item
      if data.is_a?(Array)
        data.map.with_index { |item, i| { "output_#{i}": item } }
      else
        [{ output_0: data }]
      end
    end
  end
end
