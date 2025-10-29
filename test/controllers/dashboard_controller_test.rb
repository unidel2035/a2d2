require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get dashboard_index_url
    assert_response :success
  end

  test "should render Phlex component" do
    get dashboard_index_url
    assert_response :success
    # Проверяем, что Dashboard текст присутствует в ответе
    assert_match /Dashboard/, response.body
  end

  test "should include welcome message" do
    get dashboard_index_url
    assert_response :success
    # Проверяем наличие приветственного сообщения
    assert_match /Добро пожаловать|A2D2/, response.body
  end

  test "should display stats cards" do
    get dashboard_index_url
    assert_response :success
    # Проверяем наличие статистических карточек
    assert_match /Всего агентов|Активные задачи/, response.body
  end
end
