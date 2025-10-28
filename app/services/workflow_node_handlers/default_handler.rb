# frozen_string_literal: true

module WorkflowNodeHandlers
  # Default handler for unknown node types - just passes data through
  class DefaultHandler < BaseHandler
    def execute(input_data, parameters, execution_context)
      {
        data: input_data,
        output: input_data,
        message: 'Node executed with default handler (pass-through)'
      }
    end
  end
end
