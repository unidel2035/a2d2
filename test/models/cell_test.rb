require "test_helper"

class CellTest < ActiveSupport::TestCase
  def setup
    @spreadsheet = create(:spreadsheet)
    @sheet = create(:sheet, spreadsheet: @spreadsheet)
    @row = create(:row, sheet: @sheet)
    @cell = create(:cell, row: @row, column_key: "A", value: "test")
  end

  test "should be valid with required attributes" do
    assert @cell.valid?
  end

  test "should require column_key" do
    @cell.column_key = nil
    assert_not @cell.valid?
    assert_includes @cell.errors[:column_key], "can't be blank"
  end

  test "should enforce unique column_key per row" do
    duplicate_cell = build(:cell, row: @row, column_key: @cell.column_key)
    assert_not duplicate_cell.valid?
    assert_includes duplicate_cell.errors[:column_key], "has already been taken"
  end

  test "should allow same column_key in different rows" do
    other_row = create(:row, sheet: @sheet)
    other_cell = build(:cell, row: other_row, column_key: @cell.column_key)
    assert other_cell.valid?
  end

  test "computed_value should return nil when value and formula are blank" do
    @cell.value = nil
    @cell.formula = nil
    assert_nil @cell.computed_value
  end

  test "computed_value should return parsed string value" do
    @cell.value = "Hello World"
    @cell.data_type = "string"
    @cell.formula = nil
    assert_equal "Hello World", @cell.computed_value
  end

  test "computed_value should return parsed integer value" do
    @cell.value = "42"
    @cell.data_type = "integer"
    @cell.formula = nil
    assert_equal 42, @cell.computed_value
  end

  test "computed_value should return parsed decimal value" do
    @cell.value = "3.14"
    @cell.data_type = "decimal"
    @cell.formula = nil
    assert_equal 3.14, @cell.computed_value
  end

  test "computed_value should return parsed boolean value" do
    @cell.value = "true"
    @cell.data_type = "boolean"
    @cell.formula = nil
    assert_equal true, @cell.computed_value

    @cell.value = "false"
    assert_equal false, @cell.computed_value
  end

  test "computed_value should return parsed date value" do
    date = Date.today
    @cell.value = date.to_s
    @cell.data_type = "date"
    @cell.formula = nil
    assert_equal date, @cell.computed_value
  end

  test "computed_value should handle invalid date gracefully" do
    @cell.value = "invalid-date"
    @cell.data_type = "date"
    @cell.formula = nil
    assert_equal "invalid-date", @cell.computed_value
  end

  test "has_formula? should return true when formula is present" do
    @cell.formula = "=A1+B1"
    assert @cell.has_formula?
  end

  test "has_formula? should return false when formula is blank" do
    @cell.formula = nil
    assert_not @cell.has_formula?
  end

  test "should access sheet through row" do
    assert_equal @sheet, @cell.sheet
  end

  test "should access spreadsheet through row and sheet" do
    assert_equal @spreadsheet, @cell.spreadsheet
  end

  test "computed_value should evaluate formula when present" do
    @cell.formula = "=1+1"
    @cell.value = nil
    # Formula evaluation will depend on FormulaEvaluator implementation
    # This test ensures the method is called without errors
    result = @cell.computed_value
    assert_not_nil result
  end

  test "computed_value should handle formula errors gracefully" do
    @cell.formula = "=INVALID_FORMULA"
    @cell.value = nil
    result = @cell.computed_value
    assert_match(/ERROR/, result.to_s)
  end
end
