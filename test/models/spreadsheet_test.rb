require "test_helper"

class SpreadsheetTest < ActiveSupport::TestCase
  test "should create spreadsheet with name" do
    spreadsheet = Spreadsheet.new(name: "Test Spreadsheet")
    assert spreadsheet.valid?
  end

  test "should require name" do
    spreadsheet = Spreadsheet.new
    assert_not spreadsheet.valid?
    assert_includes spreadsheet.errors[:name], "can't be blank"
  end

  test "should generate share token on creation" do
    spreadsheet = Spreadsheet.create!(name: "Test")
    assert_not_nil spreadsheet.share_token
  end

  test "should have many sheets" do
    spreadsheet = Spreadsheet.create!(name: "Test")
    sheet1 = spreadsheet.sheets.create!(name: "Sheet 1")
    sheet2 = spreadsheet.sheets.create!(name: "Sheet 2")

    assert_equal 2, spreadsheet.sheets.count
    assert_includes spreadsheet.sheets, sheet1
    assert_includes spreadsheet.sheets, sheet2
  end

  test "should check accessibility for public spreadsheet" do
    spreadsheet = Spreadsheet.create!(name: "Public", public: true)
    assert spreadsheet.accessible_by?(999) # Any user ID
  end

  test "should check accessibility for owner" do
    spreadsheet = Spreadsheet.create!(name: "Private", owner_id: 1, public: false)
    assert spreadsheet.accessible_by?(1)
    assert_not spreadsheet.accessible_by?(2)
  end
end
