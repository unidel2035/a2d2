require "test_helper"

class Agents::IndexViewTest < ActiveSupport::TestCase
  def setup
    @agents = [
      Agent.new(
        id: 1,
        name: "Analyzer Agent",
        agent_type: "analyzer",
        status: :active
      ),
      Agent.new(
        id: 2,
        name: "Transformer Agent",
        agent_type: "transformer",
        status: :idle
      )
    ]
    @stats = {
      total: 2,
      active: 1,
      idle: 1,
      busy: 0,
      failed: 0
    }
    @recent_tasks = []
  end

  test "renders agents list title" do
    skip "Requires Agents::IndexView implementation check"

    view = Agents::IndexView.new(agents: @agents, stats: @stats, recent_tasks: @recent_tasks)
    html = view.call

    assert_includes html, "Агенты" rescue assert_includes html, "Agents"
  end

  test "renders agents statistics" do
    skip "Requires Agents::IndexView implementation check"

    view = Agents::IndexView.new(agents: @agents, stats: @stats, recent_tasks: @recent_tasks)
    html = view.call

    # Проверяем отображение статистики
    assert_includes html, "2" # total
    assert_includes html, "1" # active
  end

  test "renders agents list" do
    skip "Requires Agents::IndexView implementation check"

    view = Agents::IndexView.new(agents: @agents, stats: @stats, recent_tasks: @recent_tasks)
    html = view.call

    assert_includes html, "Analyzer Agent"
    assert_includes html, "Transformer Agent"
  end
end
