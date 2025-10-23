class FormulaEvaluator
  class FormulaError < StandardError; end

  FUNCTIONS = {
    'SUM' => ->(values) { values.compact.sum },
    'AVG' => ->(values) { values.compact.sum / [values.compact.size, 1].max.to_f },
    'COUNT' => ->(values) { values.compact.size },
    'MIN' => ->(values) { values.compact.min },
    'MAX' => ->(values) { values.compact.max },
    'IF' => ->(condition, true_val, false_val) { condition ? true_val : false_val }
  }.freeze

  def self.evaluate(formula, row:, cell:)
    new(formula, row: row, cell: cell).evaluate
  end

  def initialize(formula, row:, cell:)
    @formula = formula.to_s.strip
    @row = row
    @cell = cell
    @sheet = row.sheet
  end

  def evaluate
    # Remove leading = if present
    expr = @formula.start_with?('=') ? @formula[1..-1] : @formula

    # Handle basic operations
    result = parse_expression(expr)
    result
  rescue => e
    "#ERROR: #{e.message}"
  end

  private

  def parse_expression(expr)
    expr = expr.strip

    # Handle function calls like SUM(A1:A10)
    if expr =~ /^([A-Z]+)\((.*)\)$/
      function_name = $1
      args_str = $2
      return evaluate_function(function_name, args_str)
    end

    # Handle cell references like A1, B2
    if expr =~ /^([A-Z]+)(\d+)$/
      return get_cell_value($1, $2.to_i)
    end

    # Handle range references like A1:A10
    if expr =~ /^([A-Z]+)(\d+):([A-Z]+)(\d+)$/
      return get_range_values($1, $2.to_i, $3, $4.to_i)
    end

    # Handle basic arithmetic: +, -, *, /
    if expr =~ /^(.+)\s*([\+\-\*\/])\s*(.+)$/
      left = parse_expression($1)
      operator = $2
      right = parse_expression($3)
      return calculate_operation(left, operator, right)
    end

    # Handle string literals (quoted)
    if expr =~ /^["'](.*)["']$/
      return $1
    end

    # Handle numbers
    if expr =~ /^-?\d+(\.\d+)?$/
      return expr.include?('.') ? expr.to_f : expr.to_i
    end

    # Handle boolean
    return true if expr.downcase == 'true'
    return false if expr.downcase == 'false'

    # Return as string if nothing else matches
    expr
  end

  def evaluate_function(name, args_str)
    function = FUNCTIONS[name.upcase]
    raise FormulaError, "Unknown function: #{name}" unless function

    # Parse arguments
    args = parse_arguments(args_str)

    # Handle range argument for aggregate functions
    if args.size == 1 && args[0].is_a?(Array)
      args = args[0]
    end

    function.call(*args)
  end

  def parse_arguments(args_str)
    args_str.split(',').map { |arg| parse_expression(arg.strip) }
  end

  def get_cell_value(col_key, row_position)
    target_row = @sheet.rows.find_by(position: row_position)
    return nil unless target_row

    target_row.cell_value(col_key)
  end

  def get_range_values(start_col, start_row, end_col, end_row)
    values = []

    # For now, only support same column ranges (A1:A10)
    if start_col == end_col
      (start_row..end_row).each do |pos|
        target_row = @sheet.rows.find_by(position: pos)
        values << target_row.cell_value(start_col) if target_row
      end
    else
      raise FormulaError, "Multi-column ranges not yet supported"
    end

    values
  end

  def calculate_operation(left, operator, right)
    left = left.to_f if left.is_a?(String) && left =~ /^-?\d+(\.\d+)?$/
    right = right.to_f if right.is_a?(String) && right =~ /^-?\d+(\.\d+)?$/

    case operator
    when '+'
      left + right
    when '-'
      left - right
    when '*'
      left * right
    when '/'
      raise FormulaError, "Division by zero" if right.zero?
      left / right
    else
      raise FormulaError, "Unknown operator: #{operator}"
    end
  end
end
