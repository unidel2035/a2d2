require "test_helper"

class AgroOrchestratorTest < ActiveSupport::TestCase
  def setup
    @orchestrator = AgroOrchestrator.new

    # Создаем тестовых агентов
    @agent1 = AgroAgent.create!(
      name: "Фермерский агент 1",
      agent_type: "farmer",
      level: "operational",
      status: "active",
      capabilities: ["harvesting", "planting"],
      last_heartbeat: 1.minute.ago
    )

    @agent2 = AgroAgent.create!(
      name: "Фермерский агент 2",
      agent_type: "farmer",
      level: "operational",
      status: "active",
      capabilities: ["harvesting", "irrigation"],
      last_heartbeat: 2.minutes.ago
    )

    @agent3 = AgroAgent.create!(
      name: "Процессорный агент",
      agent_type: "processor",
      level: "tactical",
      status: "active",
      capabilities: ["processing", "quality_control"],
      last_heartbeat: 30.seconds.ago
    )
  end

  test "должен назначать задачу подходящему агенту" do
    result = @orchestrator.assign_task("harvesting", { field: "A1" })

    assert result[:success]
    assert result[:task_id].present?
    assert result[:agent_id].present?

    task = AgroTask.find(result[:task_id])
    assert_equal "harvesting", task.task_type
    assert_includes [@agent1.id, @agent2.id], task.agro_agent_id
  end

  test "должен выбирать наименее загруженного агента" do
    # Загружаем первого агента задачами
    5.times do
      @agent1.agro_tasks.create!(task_type: "harvesting", status: "pending")
    end

    result = @orchestrator.assign_task("harvesting", { field: "B1" })

    assert result[:success]
    task = AgroTask.find(result[:task_id])
    # Должен выбрать agent2, так как у него меньше задач
    assert_equal @agent2.id, task.agro_agent_id
  end

  test "должен возвращать ошибку если нет подходящих агентов" do
    result = @orchestrator.assign_task("flying", { height: 100 })

    assert result[:error].present?
    assert_equal "No suitable agents found", result[:error]
  end

  test "должен устанавливать приоритет задачи" do
    result = @orchestrator.assign_task("harvesting", { field: "C1" }, priority: "high")

    assert result[:success]
    task = AgroTask.find(result[:task_id])
    assert_equal "high", task.priority
  end

  test "должен координировать последовательный workflow" do
    result = @orchestrator.coordinate_workflow(
      "workflow",
      [@agent1.id, @agent2.id],
      {
        "steps" => [
          { "task_type" => "planting", "input" => { "field" => "D1" } },
          { "task_type" => "irrigation", "input" => { "field" => "D1" } }
        ]
      }
    )

    assert result[:success]
    assert_equal 2, result[:tasks_created]
    assert @orchestrator.coordination.present?
  end

  test "должен мониторить экосистему агентов" do
    stats = @orchestrator.monitor_ecosystem

    assert_equal 3, stats[:total_agents]
    assert_equal 3, stats[:active_agents]
    assert stats[:online_agents] > 0
    assert stats[:pending_tasks] >= 0
  end

  test "должен проверять здоровье агентов" do
    health = @orchestrator.health_check

    assert_equal 3, health.size

    agent_health = health.find { |h| h[:agent_id] == @agent1.id }
    assert agent_health.present?
    assert_equal @agent1.name, agent_health[:name]
    assert_equal "active", agent_health[:status]
    assert agent_health[:online]
  end

  test "должен перебалансировать задачи между агентами" do
    # Создаем много задач для первого агента
    15.times do
      @agent1.agro_tasks.create!(
        task_type: "harvesting",
        status: "pending",
        priority: "normal"
      )
    end

    result = @orchestrator.rebalance_tasks

    assert result[:rebalanced_tasks] > 0
    assert result[:overloaded_agents] > 0
  end

  test "должен создавать координацию для переговоров" do
    result = @orchestrator.coordinate_workflow(
      "negotiation",
      [@agent1.id, @agent2.id],
      { "topic" => "resource_sharing" }
    )

    assert result[:success]
    assert_equal @orchestrator.coordination.id, result[:negotiation_id]
    assert_equal [@agent1.id, @agent2.id], result[:participants]
  end

  test "должен оптимизировать ресурсы" do
    result = @orchestrator.coordinate_workflow(
      "optimization",
      [@agent1.id, @agent2.id, @agent3.id],
      { "resource_type" => "equipment" }
    )

    assert result[:success]
    assert_equal 3, result[:resources].size
    assert_equal "completed", result[:optimization]
  end

  test "должен находить подходящих агентов по уровню" do
    # Используем private метод через send для тестирования
    agents = @orchestrator.send(:find_suitable_agents, "harvesting", level: "operational")

    assert_equal 2, agents.size
    assert_includes agents.map(&:id), @agent1.id
    assert_includes agents.map(&:id), @agent2.id
    refute_includes agents.map(&:id), @agent3.id
  end

  test "должен вычислять доступную мощность агента" do
    # Добавляем несколько задач
    3.times do
      @agent1.agro_tasks.create!(task_type: "harvesting", status: "pending")
    end

    capacity = @orchestrator.send(:calculate_capacity, @agent1)

    assert_equal 17, capacity # 20 - 3 = 17
  end

  test "должен корректно обрабатывать неактивных агентов" do
    @agent1.update(status: "inactive")

    result = @orchestrator.assign_task("harvesting", { field: "E1" })

    assert result[:success]
    # Должен назначить активному агенту
    task = AgroTask.find(result[:task_id])
    assert_not_equal @agent1.id, task.agro_agent_id
  end
end
