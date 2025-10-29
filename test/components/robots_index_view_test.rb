require "test_helper"

class Robots::IndexViewTest < ActiveSupport::TestCase
  def setup
    @robots = [
      Robot.new(
        id: 1,
        manufacturer: "TestCorp",
        model: "RB-100",
        serial_number: "SN-001",
        status: :active
      ),
      Robot.new(
        id: 2,
        manufacturer: "RoboCorp",
        model: "RB-200",
        serial_number: "SN-002",
        status: :maintenance
      )
    ]
  end

  test "renders robots list title" do
    skip "Requires Robots::IndexView implementation"

    view = Robots::IndexView.new(robots: @robots)
    html = view.call

    assert_includes html, "Роботы" rescue assert_includes html, "Robots"
  end

  test "renders robots data" do
    skip "Requires Robots::IndexView implementation"

    view = Robots::IndexView.new(robots: @robots)
    html = view.call

    assert_includes html, "SN-001"
    assert_includes html, "SN-002"
    assert_includes html, "TestCorp"
    assert_includes html, "RoboCorp"
  end

  test "renders empty state when no robots" do
    skip "Requires Robots::IndexView implementation"

    view = Robots::IndexView.new(robots: [])
    html = view.call

    # Проверка на пустое состояние
    assert_includes html, "Нет роботов" rescue assert_includes html, "No robots"
  end
end
