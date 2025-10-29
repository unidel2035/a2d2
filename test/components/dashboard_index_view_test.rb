require "test_helper"

class DashboardViews::IndexViewTest < ActiveSupport::TestCase
  test "renders dashboard title" do
    view = DashboardViews::IndexView.new
    html = view.call

    assert_includes html, "Dashboard"
  end

  test "renders welcome message" do
    view = DashboardViews::IndexView.new
    html = view.call

    assert_includes html, "Добро пожаловать"
    assert_includes html, "A2D2"
  end

  test "renders stats cards" do
    view = DashboardViews::IndexView.new
    html = view.call

    # Проверяем наличие статистических карточек
    assert_includes html, "Всего агентов"
    assert_includes html, "Активные задачи"
    assert_includes html, "Требуют внимания"
    assert_includes html, "Операторы онлайн"
  end

  test "renders quick actions" do
    view = DashboardViews::IndexView.new
    html = view.call

    # Проверяем наличие быстрых действий
    assert_includes html, "New Task"
    assert_includes html, "New Inspection"
    assert_includes html, "Add Robot"
    assert_includes html, "Generate Report"
  end

  test "renders recent activity section" do
    view = DashboardViews::IndexView.new
    html = view.call

    assert_includes html, "Recent Activity"
  end

  test "renders chart placeholders" do
    view = DashboardViews::IndexView.new
    html = view.call

    assert_includes html, "Task Statistics"
    assert_includes html, "Robot Usage"
  end
end
