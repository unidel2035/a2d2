require "test_helper"

class AgroAgentTest < ActiveSupport::TestCase
  def setup
    @agent = AgroAgent.create!(
      name: "Тестовый агент",
      agent_type: "farmer",
      level: "operational",
      status: "active"
    )
  end

  test "должен создавать агента с валидными атрибутами" do
    assert @agent.valid?
    assert_equal "Тестовый агент", @agent.name
    assert_equal "farmer", @agent.agent_type
    assert_equal "operational", @agent.level
    assert_equal "active", @agent.status
  end

  test "должен инициализировать значения по умолчанию" do
    agent = AgroAgent.create!(
      name: "Новый агент",
      agent_type: "processor",
      level: "tactical"
    )

    assert_equal [], agent.capability_list
    assert_equal({}, agent.configuration)
    assert_equal 100.0, agent.success_rate
    assert_equal 0, agent.tasks_completed
    assert_equal 0, agent.tasks_failed
    assert_equal "active", agent.status
  end

  test "должен требовать обязательные поля" do
    agent = AgroAgent.new

    refute agent.valid?
    assert_includes agent.errors[:name], "can't be blank"
    assert_includes agent.errors[:agent_type], "can't be blank"
    assert_includes agent.errors[:level], "can't be blank"
  end

  test "должен валидировать статус" do
    @agent.status = "invalid_status"
    refute @agent.valid?
  end

  test "должен проверять онлайн статус" do
    @agent.update(last_heartbeat: 2.minutes.ago)
    assert @agent.online?

    @agent.update(last_heartbeat: 10.minutes.ago)
    refute @agent.online?
  end

  test "должен управлять возможностями" do
    assert_equal [], @agent.capability_list

    @agent.add_capability("harvesting")
    assert_includes @agent.capability_list, "harvesting"
    assert @agent.has_capability?("harvesting")

    @agent.add_capability("planting")
    assert_equal 2, @agent.capability_list.size
  end

  test "должен обновлять heartbeat" do
    old_heartbeat = @agent.last_heartbeat
    sleep 0.1
    @agent.heartbeat!

    assert @agent.last_heartbeat > old_heartbeat if old_heartbeat
  end

  test "должен обновлять статистику задач" do
    assert_equal 0, @agent.tasks_completed
    assert_equal 0, @agent.tasks_failed
    assert_equal 100.0, @agent.success_rate

    @agent.update_task_stats(success: true)
    assert_equal 1, @agent.tasks_completed
    assert_equal 100.0, @agent.success_rate

    @agent.update_task_stats(success: false)
    assert_equal 1, @agent.tasks_failed
    assert_equal 50.0, @agent.success_rate
  end

  test "должен возвращать отчет о состоянии" do
    report = @agent.status_report

    assert_equal @agent.id, report[:id]
    assert_equal @agent.name, report[:name]
    assert_equal @agent.agent_type, report[:agent_type]
    assert_includes report.keys, :online
    assert_includes report.keys, :success_rate
  end

  test "должен иметь связь с задачами" do
    task = @agent.agro_tasks.create!(
      task_type: "harvesting",
      priority: "normal"
    )

    assert_equal 1, @agent.agro_tasks.count
    assert_equal task, @agent.agro_tasks.first
  end

  test "должен фильтровать по статусу через скоупы" do
    AgroAgent.create!(name: "A1", agent_type: "farmer", level: "operational", status: "active")
    AgroAgent.create!(name: "A2", agent_type: "farmer", level: "operational", status: "inactive")

    assert_equal 2, AgroAgent.active.count
    assert_equal 1, AgroAgent.inactive.count
  end
end
