# frozen_string_literal: true

module WorkflowNodeHandlers
  # Base handler for all node types
  class BaseHandler
    def execute(input_data, parameters, execution_context)
      raise NotImplementedError, "#{self.class.name} must implement execute method"
    end

    protected

    # Helper to safely access nested data
    def safe_dig(data, *keys)
      keys.reduce(data) do |result, key|
        break nil if result.nil?

        if result.is_a?(Hash)
          result[key.to_s] || result[key.to_sym]
        elsif result.is_a?(Array) && key.is_a?(Integer)
          result[key]
        else
          nil
        end
      end
    end

    # Helper to evaluate expressions (simplified n8n-style expressions)
    def evaluate_expression(expression, data)
      # Simple variable replacement like {{$json.field}}
      return expression unless expression.is_a?(String)

      expression.gsub(/\{\{([^}]+)\}\}/) do |_match|
        path = Regexp.last_match(1).strip
        evaluate_path(path, data)
      end
    end

    # Evaluate a path expression like $json.field.subfield
    def evaluate_path(path, data)
      parts = path.split('.')
      current = data

      parts.each do |part|
        case part
        when '$json'
          current = data
        when /^\d+$/
          current = current[part.to_i] if current.is_a?(Array)
        else
          current = safe_dig(current, part)
        end

        break if current.nil?
      end

      current
    end
  end
end
