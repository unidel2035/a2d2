require "application_system_test_case"

class RobotsTest < ApplicationSystemTestCase
  def setup
    @robot = robots(:one)
  end

  test "viewing robots list" do
    skip "Authentication setup required for system tests"

    visit robots_url

    assert_selector "h1", text: /Роботы|Robots/i
    assert_text @robot.serial_number
  end

  test "creating a new robot" do
    skip "Authentication setup required for system tests"

    visit robots_url
    click_on "Новый робот", match: :first rescue click_on "New Robot", match: :first

    fill_in "Производитель", with: "Test Robot Corp" rescue fill_in "Manufacturer", with: "Test Robot Corp"
    fill_in "Модель", with: "RB-TEST" rescue fill_in "Model", with: "RB-TEST"
    fill_in "Серийный номер", with: "SN-TEST-001" rescue fill_in "Serial number", with: "SN-TEST-001"

    click_on "Создать", match: :first rescue click_on "Create", match: :first

    assert_text "успешно создан" rescue assert_text "successfully created"
    assert_text "SN-TEST-001"
  end

  test "showing robot details" do
    skip "Authentication setup required for system tests"

    visit robot_url(@robot)

    assert_text @robot.serial_number
    assert_text @robot.manufacturer
  end

  test "editing a robot" do
    skip "Authentication setup required for system tests"

    visit robot_url(@robot)
    click_on "Редактировать", match: :first rescue click_on "Edit", match: :first

    fill_in "Производитель", with: "Updated Corp" rescue fill_in "Manufacturer", with: "Updated Corp"
    click_on "Обновить", match: :first rescue click_on "Update", match: :first

    assert_text "успешно обновлен" rescue assert_text "successfully updated"
    assert_text "Updated Corp"
  end

  test "deleting a robot" do
    skip "Authentication setup required for system tests"

    visit robots_url

    accept_confirm do
      click_on "Удалить", match: :first rescue click_on "Delete", match: :first
    end

    assert_text "успешно удален" rescue assert_text "successfully deleted"
  end

  test "filtering robots by status" do
    skip "Authentication setup required for system tests"

    visit robots_url

    # Если есть фильтр по статусу
    # select "active", from: "status"
    # click_button "Filter"

    # assert_selector "table tbody tr", minimum: 1
  end

  test "searching for robots" do
    skip "Authentication setup required for system tests"

    visit robots_url

    # Если есть поиск
    # fill_in "search", with: @robot.serial_number
    # click_button "Search"

    # assert_text @robot.serial_number
  end
end
