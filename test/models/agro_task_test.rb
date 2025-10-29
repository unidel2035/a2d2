require "test_helper"

class AgroTaskTest < ActiveSupport::TestCase
  def setup
    @agent = AgroAgent.create!(
      name: "Тестовый агент",
      agent_type: "farmer",
      level: "operational",
      status: "active"
    )

    @task = AgroTask.create!(
      task_type: "harvesting",
      priority: "normal",
      agro_agent: @agent
    )
  end

  test "должен создавать задачу с валидными атрибутами" do
    assert @task.valid?
    assert_equal "harvesting", @task.task_type
    assert_equal "normal", @task.priority
    assert_equal "pending", @task.status
  end

  test "должен инициализировать значения по умолчанию" do
    task = AgroTask.create!(task_type: "planting")

    assert_equal({}, task.input_data)
    assert_equal({}, task.output_data)
    assert_equal "pending", task.status
    assert_equal "normal", task.priority
    assert_equal 0, task.retry_count
  end

  test "должен требовать обязательные поля" do
    task = AgroTask.new

    refute task.valid?
    assert_includes task.errors[:task_type], "can't be blank"
  end

  test "должен валидировать статус" do
    @task.status = "invalid_status"
    refute @task.valid?
  end

  test "должен валидировать приоритет" do
    @task.priority = "invalid_priority"
    refute @task.valid?

    @task.priority = "high"
    assert @task.valid?
  end

  test "должен проверять состояния задачи" do
    assert @task.pending?
    refute @task.running?
    refute @task.completed?
    refute @task.failed?
  end

  test "должен переходить в состояние running" do
    assert @task.start!

    @task.reload
    assert @task.running?
    assert @task.started_at.present?
  end

  test "должен завершаться успешно" do
    @task.start!
    output = { result: "success", data: "test" }

    assert @task.complete!(output)

    @task.reload
    assert @task.completed?
    assert_equal output, @task.output_data
    assert @task.completed_at.present?
  end

  test "должен завершаться с ошибкой" do
    @task.start!

    @task.fail!("Ошибка выполнения")

    @task.reload
    assert @task.failed?
    assert_equal "Ошибка выполнения", @task.error_message
    assert @task.completed_at.present?
  end

  test "должен поддерживать повторные попытки" do
    @task.update(status: "failed")

    assert @task.retry!

    @task.reload
    assert @task.pending?
    assert_equal 1, @task.retry_count
  end

  test "должен ограничивать количество повторов" do
    @task.update(status: "failed", retry_count: 3)

    refute @task.retry!
  end

  test "должен вычислять длительность выполнения" do
    @task.start!
    sleep 0.1
    @task.complete!({})

    assert @task.duration > 0
  end

  test "должен поддерживать отмену" do
    assert @task.cancel!

    @task.reload
    assert @task.cancelled?
  end

  test "должен фильтровать по статусу через скоупы" do
    AgroTask.create!(task_type: "t1", status: "pending")
    AgroTask.create!(task_type: "t2", status: "running")
    AgroTask.create!(task_type: "t3", status: "completed")

    assert_equal 2, AgroTask.pending.count
    assert_equal 1, AgroTask.running.count
    assert_equal 1, AgroTask.completed.count
  end

  test "должен фильтровать по приоритету" do
    AgroTask.create!(task_type: "t1", priority: "high")
    AgroTask.create!(task_type: "t2", priority: "urgent")
    AgroTask.create!(task_type: "t3", priority: "low")

    assert_equal 2, AgroTask.high_priority.count
  end

  test "должен иметь связь с агентом" do
    assert_equal @agent, @task.agro_agent
  end

  test "должен переназначать агенту" do
    new_agent = AgroAgent.create!(
      name: "Новый агент",
      agent_type: "processor",
      level: "tactical"
    )

    assert @task.reassign_to(new_agent)

    @task.reload
    assert_equal new_agent, @task.agro_agent
  end
end
