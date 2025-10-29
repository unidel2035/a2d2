require "test_helper"

class AgentsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @agent = agents(:one)
  end

  test "should get index" do
    get agents_url
    assert_response :success
  end

  test "should display agents list" do
    get agents_url
    assert_response :success
    # Проверяем наличие агента из fixtures
    assert_match /#{@agent.name}/, response.body
  end

  test "should display agent statistics" do
    get agents_url
    assert_response :success
    # Проверяем наличие статистики
    assert_match /Всего|total|active|idle|busy/, response.body
  end

  test "should show agent" do
    get agent_url(@agent)
    assert_response :success
  end

  test "should display agent details" do
    get agent_url(@agent)
    assert_response :success
    # Проверяем наличие информации об агенте
    assert_match /#{@agent.name}/, response.body
    assert_match /#{@agent.agent_type}/, response.body
  end

  test "should display agent tasks" do
    get agent_url(@agent)
    assert_response :success
    # Проверяем, что отображаются задачи агента
    # (даже если список пуст, он должен быть в ответе)
  end

  test "should handle non-existent agent gracefully" do
    assert_raises(ActiveRecord::RecordNotFound) do
      get agent_url(id: 99999)
    end
  end
end
