module Agents
  class ValidatorAgent < Agent
    def initialize(attributes = {})
      super
      self.type ||= "Agents::ValidatorAgent"
      self.capabilities ||= {
        business_rules_validation: true,
        schema_validation: true,
        data_quality_scoring: true,
        constraint_checking: true,
        validation_reporting: true
      }
    end

    def execute(task)
      data = task.input_data["data"]
      validation_type = task.input_data["validation_type"]
      rules = task.input_data["rules"] || {}

      case validation_type
      when "schema"
        validate_schema(data, rules)
      when "business_rules"
        validate_business_rules(data, rules)
      when "quality"
        score_data_quality(data)
      when "constraints"
        check_constraints(data, rules)
      when "comprehensive"
        {
          schema: validate_schema(data, rules.dig("schema") || {}),
          business_rules: validate_business_rules(data, rules.dig("business_rules") || {}),
          quality_score: score_data_quality(data),
          constraints: check_constraints(data, rules.dig("constraints") || {})
        }
      else
        { error: "Unknown validation type: #{validation_type}" }
      end
    end

    private

    def validate_schema(data, schema)
      return { valid: false, errors: [ "Schema must be provided" ] } if schema.empty?

      errors = []

      case data
      when Hash
        schema.each do |field, requirements|
          validate_field(data, field, requirements, errors)
        end
      when Array
        data.each_with_index do |item, index|
          next unless item.is_a?(Hash)

          schema.each do |field, requirements|
            validate_field(item, field, requirements, errors, prefix: "[#{index}]")
          end
        end
      else
        errors << "Data must be a Hash or Array for schema validation"
      end

      {
        valid: errors.empty?,
        errors: errors,
        fields_validated: schema.keys.size
      }
    end

    def validate_field(data, field, requirements, errors, prefix: "")
      field_path = "#{prefix}#{field}"
      value = data[field] || data[field.to_sym]

      # Required check
      if requirements["required"] && value.nil?
        errors << "#{field_path} is required but missing"
        return
      end

      return if value.nil? # Skip other validations if not required and missing

      # Type check
      if requirements["type"]
        expected_type = requirements["type"].to_s
        actual_type = value.class.name.downcase

        unless type_matches?(actual_type, expected_type)
          errors << "#{field_path} has type #{actual_type}, expected #{expected_type}"
        end
      end

      # Format check (for strings)
      if requirements["format"] && value.is_a?(String)
        format_pattern = case requirements["format"]
        when "email"
          /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
        when "url"
          %r{\Ahttps?://}
        when "date"
          /\A\d{4}-\d{2}-\d{2}\z/
        else
          nil
        end

        if format_pattern && !value.match?(format_pattern)
          errors << "#{field_path} has invalid format: expected #{requirements['format']}"
        end
      end

      # Range check (for numbers)
      if value.is_a?(Numeric)
        if requirements["min"] && value < requirements["min"]
          errors << "#{field_path} is #{value}, minimum is #{requirements['min']}"
        end

        if requirements["max"] && value > requirements["max"]
          errors << "#{field_path} is #{value}, maximum is #{requirements['max']}"
        end
      end

      # Length check (for strings/arrays)
      if value.respond_to?(:length)
        if requirements["min_length"] && value.length < requirements["min_length"]
          errors << "#{field_path} length is #{value.length}, minimum is #{requirements['min_length']}"
        end

        if requirements["max_length"] && value.length > requirements["max_length"]
          errors << "#{field_path} length is #{value.length}, maximum is #{requirements['max_length']}"
        end
      end
    end

    def type_matches?(actual, expected)
      case expected.downcase
      when "string" then actual == "string"
      when "integer" then [ "integer", "fixnum", "bignum" ].include?(actual)
      when "float", "number", "numeric" then [ "float", "integer", "fixnum", "bignum" ].include?(actual)
      when "boolean" then [ "trueclass", "falseclass" ].include?(actual)
      when "array" then actual == "array"
      when "hash", "object" then actual == "hash"
      else false
      end
    end

    def validate_business_rules(data, rules)
      return { valid: true, violations: [] } if rules.empty?

      violations = []

      rules.each do |rule_name, rule_definition|
        next unless rule_definition.is_a?(Hash)

        # Simple rule evaluation
        field = rule_definition["field"]
        operator = rule_definition["operator"]
        value = rule_definition["value"]

        data_value = data.is_a?(Hash) ? (data[field] || data[field.to_sym]) : nil

        unless evaluate_condition(data_value, operator, value)
          violations << {
            rule: rule_name,
            field: field,
            message: rule_definition["message"] || "Business rule violated"
          }
        end
      end

      {
        valid: violations.empty?,
        violations: violations,
        rules_checked: rules.keys.size
      }
    end

    def evaluate_condition(data_value, operator, expected_value)
      case operator
      when "equals", "eq" then data_value == expected_value
      when "not_equals", "ne" then data_value != expected_value
      when "greater_than", "gt" then data_value.to_f > expected_value.to_f
      when "less_than", "lt" then data_value.to_f < expected_value.to_f
      when "greater_or_equal", "gte" then data_value.to_f >= expected_value.to_f
      when "less_or_equal", "lte" then data_value.to_f <= expected_value.to_f
      when "contains" then data_value.to_s.include?(expected_value.to_s)
      when "matches" then data_value.to_s.match?(Regexp.new(expected_value.to_s))
      else true
      end
    end

    def score_data_quality(data)
      score = 100
      issues = []

      case data
      when Hash
        score, issues = score_hash_quality(data)
      when Array
        total_score = 0
        all_issues = []

        data.each_with_index do |item, index|
          item_score, item_issues = score_hash_quality(item)
          total_score += item_score
          all_issues.concat(item_issues.map { |i| "[#{index}] #{i}" })
        end

        score = data.empty? ? 0 : (total_score / data.size)
        issues = all_issues
      else
        issues << "Data type not suitable for quality scoring"
        score = 0
      end

      {
        quality_score: score,
        grade: quality_grade(score),
        issues: issues
      }
    end

    def score_hash_quality(data)
      return [ 0, [ "Data is not a hash" ] ] unless data.is_a?(Hash)

      score = 100
      issues = []

      # Check for completeness (no nil values)
      nil_count = data.values.count(&:nil?)
      if nil_count.positive?
        penalty = (nil_count.to_f / data.size * 30).round
        score -= penalty
        issues << "#{nil_count} fields have nil values (-#{penalty} points)"
      end

      # Check for empty strings
      empty_string_count = data.values.count { |v| v.is_a?(String) && v.strip.empty? }
      if empty_string_count.positive?
        penalty = (empty_string_count.to_f / data.size * 20).round
        score -= penalty
        issues << "#{empty_string_count} fields have empty strings (-#{penalty} points)"
      end

      # Check for data variety (not all same values)
      unique_values = data.values.uniq.size
      if unique_values == 1 && data.size > 1
        score -= 10
        issues << "All values are identical (-10 points)"
      end

      [ [ score, 0 ].max, issues ]
    end

    def quality_grade(score)
      case score
      when 90..100 then "A"
      when 80...90 then "B"
      when 70...80 then "C"
      when 60...70 then "D"
      else "F"
      end
    end

    def check_constraints(data, constraints)
      return { valid: true, violations: [] } if constraints.empty?

      violations = []

      constraints.each do |constraint_name, constraint_def|
        next unless constraint_def.is_a?(Hash)

        type = constraint_def["type"]
        case type
        when "unique"
          check_uniqueness(data, constraint_def, violations)
        when "not_null"
          check_not_null(data, constraint_def, violations)
        when "foreign_key"
          # Placeholder for foreign key validation
          violations << { constraint: constraint_name, message: "Foreign key validation not implemented" }
        when "check"
          check_custom_constraint(data, constraint_def, violations, constraint_name)
        end
      end

      {
        valid: violations.empty?,
        violations: violations,
        constraints_checked: constraints.keys.size
      }
    end

    def check_uniqueness(data, constraint, violations)
      return unless data.is_a?(Array)

      field = constraint["field"]
      values = data.map { |item| item.is_a?(Hash) ? (item[field] || item[field.to_sym]) : nil }.compact

      if values.size != values.uniq.size
        duplicates = values.group_by { |v| v }.select { |_k, v| v.size > 1 }.keys
        violations << {
          constraint: "unique",
          field: field,
          message: "Duplicate values found: #{duplicates.join(', ')}"
        }
      end
    end

    def check_not_null(data, constraint, violations)
      field = constraint["field"]

      case data
      when Hash
        value = data[field] || data[field.to_sym]
        violations << { constraint: "not_null", field: field, message: "Field is null" } if value.nil?
      when Array
        data.each_with_index do |item, index|
          next unless item.is_a?(Hash)

          value = item[field] || item[field.to_sym]
          violations << { constraint: "not_null", field: "#{field}[#{index}]", message: "Field is null" } if value.nil?
        end
      end
    end

    def check_custom_constraint(data, constraint, violations, constraint_name)
      # Placeholder for custom constraint checking
      violations << {
        constraint: constraint_name,
        message: "Custom constraint validation not fully implemented"
      }
    end
  end
end
