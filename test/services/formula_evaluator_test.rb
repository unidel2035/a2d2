require "test_helper"

class FormulaEvaluatorTest < ActiveSupport::TestCase
  def setup
    @spreadsheet = Spreadsheet.create!(name: "Test")
    @sheet = @spreadsheet.sheets.create!(name: "Sheet 1")
    @row1 = @sheet.rows.create!(position: 1)
    @row2 = @sheet.rows.create!(position: 2)
    @cell = @row1.cells.create!(column_key: 'A', value: '10', data_type: 'integer')
  end

  test "should evaluate simple number" do
    result = FormulaEvaluator.evaluate("42", row: @row1, cell: @cell)
    assert_equal 42, result
  end

  test "should evaluate basic arithmetic" do
    result = FormulaEvaluator.evaluate("10 + 5", row: @row1, cell: @cell)
    assert_equal 15, result
  end

  test "should evaluate multiplication" do
    result = FormulaEvaluator.evaluate("10 * 5", row: @row1, cell: @cell)
    assert_equal 50, result
  end

  test "should evaluate division" do
    result = FormulaEvaluator.evaluate("10 / 2", row: @row1, cell: @cell)
    assert_equal 5, result
  end

  test "should handle cell reference" do
    @row1.set_cell_value('A', '10', data_type: 'integer')
    cell_b = @row1.cells.create!(column_key: 'B', formula: 'A1')

    result = FormulaEvaluator.evaluate("A1", row: @row1, cell: cell_b)
    assert_equal 10, result
  end

  test "should evaluate SUM function" do
    @row1.set_cell_value('A', '10', data_type: 'integer')
    @row2.set_cell_value('A', '20', data_type: 'integer')

    result = FormulaEvaluator.evaluate("SUM(A1:A2)", row: @row1, cell: @cell)
    assert_equal 30, result
  end

  test "should evaluate AVG function" do
    @row1.set_cell_value('A', '10', data_type: 'integer')
    @row2.set_cell_value('A', '20', data_type: 'integer')

    result = FormulaEvaluator.evaluate("AVG(A1:A2)", row: @row1, cell: @cell)
    assert_equal 15.0, result
  end

  test "should evaluate COUNT function" do
    @row1.set_cell_value('A', '10')
    @row2.set_cell_value('A', '20')

    result = FormulaEvaluator.evaluate("COUNT(A1:A2)", row: @row1, cell: @cell)
    assert_equal 2, result
  end

  test "should evaluate MIN function" do
    @row1.set_cell_value('A', '10', data_type: 'integer')
    @row2.set_cell_value('A', '20', data_type: 'integer')

    result = FormulaEvaluator.evaluate("MIN(A1:A2)", row: @row1, cell: @cell)
    assert_equal 10, result
  end

  test "should evaluate MAX function" do
    @row1.set_cell_value('A', '10', data_type: 'integer')
    @row2.set_cell_value('A', '20', data_type: 'integer')

    result = FormulaEvaluator.evaluate("MAX(A1:A2)", row: @row1, cell: @cell)
    assert_equal 20, result
  end

  test "should handle string literals" do
    result = FormulaEvaluator.evaluate('"Hello"', row: @row1, cell: @cell)
    assert_equal "Hello", result
  end

  test "should handle boolean values" do
    result = FormulaEvaluator.evaluate('true', row: @row1, cell: @cell)
    assert_equal true, result
  end
end
