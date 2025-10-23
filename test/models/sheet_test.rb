require "test_helper"

class SheetTest < ActiveSupport::TestCase
  def setup
    @spreadsheet = Spreadsheet.create!(name: "Test Spreadsheet")
  end

  test "should create sheet with name" do
    sheet = @spreadsheet.sheets.new(name: "Sheet 1")
    assert sheet.valid?
  end

  test "should require name" do
    sheet = @spreadsheet.sheets.new
    assert_not sheet.valid?
  end

  test "should have default columns on creation" do
    sheet = @spreadsheet.sheets.create!(name: "Sheet 1")
    assert_not_empty sheet.column_definitions
    assert_equal 3, sheet.column_definitions.size
  end

  test "should add column" do
    sheet = @spreadsheet.sheets.create!(name: "Sheet 1")
    initial_count = sheet.column_definitions.size

    sheet.add_column('D', 'Column D', 'text')
    sheet.reload

    assert_equal initial_count + 1, sheet.column_definitions.size
    assert_includes sheet.column_keys, 'D'
  end

  test "should remove column" do
    sheet = @spreadsheet.sheets.create!(name: "Sheet 1")
    sheet.remove_column('A')
    sheet.reload

    assert_not_includes sheet.column_keys, 'A'
  end

  test "should add row" do
    sheet = @spreadsheet.sheets.create!(name: "Sheet 1")
    row = sheet.add_row({ 'A' => 'Test' })

    assert_not_nil row
    assert_equal 1, sheet.rows.count
  end
end
