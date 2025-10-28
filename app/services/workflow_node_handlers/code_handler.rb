# frozen_string_literal: true

module WorkflowNodeHandlers
  # Handler for Code nodes - executes custom Ruby code
  # IMPORTANT: This should be used with caution in production
  class CodeHandler < BaseHandler
    def execute(input_data, parameters, execution_context)
      code = parameters['code']
      language = parameters['language'] || 'ruby'

      unless code
        return {
          data: { error: 'No code provided' },
          output: { error: 'No code provided' },
          error: 'No code provided'
        }
      end

      result = if language == 'ruby'
                 execute_ruby_code(code, input_data, execution_context)
               else
                 { error: "Language #{language} not supported" }
               end

      {
        data: result,
        output: result
      }
    rescue StandardError => e
      {
        data: { error: e.message },
        output: { error: e.message },
        error: e.message
      }
    end

    private

    def execute_ruby_code(code, input_data, execution_context)
      # Create a sandboxed execution context
      context = ExecutionContext.new(input_data, execution_context)

      # WARNING: In production, this should use a proper sandboxing solution
      # such as safe_ruby gem or Docker containers
      context.instance_eval(code)
    rescue StandardError => e
      { error: e.message, backtrace: e.backtrace.first(5) }
    end

    # Simple context object for code execution
    class ExecutionContext
      attr_reader :input, :json, :context

      def initialize(input_data, execution_context)
        @input = input_data
        @json = input_data
        @context = execution_context
      end

      # Helper methods available in code
      def log(message)
        Rails.logger.info("[WorkflowCode] #{message}")
      end

      def now
        Time.current
      end

      def output(data)
        @output = data
      end

      def result
        @output || @input
      end
    end
  end
end
