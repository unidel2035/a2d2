require "test_helper"

class RowTest < ActiveSupport::TestCase
  def setup
    @spreadsheet = Spreadsheet.create!(name: "Test")
    @sheet = @spreadsheet.sheets.create!(name: "Sheet 1")
    @row = @sheet.rows.create!(position: 1)
  end

  test "should set cell value" do
    cell = @row.set_cell_value('A', 'Hello', data_type: 'text')

    assert_not_nil cell
    assert_equal 'Hello', cell.value
    assert_equal 'A', cell.column_key
  end

  test "should get cell value" do
    @row.set_cell_value('A', '42', data_type: 'integer')
    value = @row.cell_value('A')

    assert_equal 42, value
  end

  test "should convert to hash" do
    @row.set_cell_value('A', 'Test')
    @row.set_cell_value('B', '123')

    hash = @row.to_hash

    assert_equal @row.id, hash[:id]
    assert_equal 1, hash[:position]
    assert_equal 'Test', hash['A']
    assert_equal '123', hash['B']
  end
end
