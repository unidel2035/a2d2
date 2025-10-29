require "test_helper"

class TaskQueueManagerTest < ActiveSupport::TestCase
  def setup
    @manager = TaskQueueManager.instance
  end

  test "enqueue_task should create new task" do
    task = @manager.enqueue_task(
      task_type: "test_task",
      payload: { data: "test" },
      priority: 10
    )

    assert task.persisted?
    assert_equal "test_task", task.task_type
    assert_equal 10, task.priority
    assert_equal "pending", task.status
  end

  test "enqueue_batch should create multiple tasks" do
    tasks_data = [
      { task_type: "task1", payload: {}, priority: 1 },
      { task_type: "task2", payload: {}, priority: 2 },
      { task_type: "task3", payload: {}, priority: 3 }
    ]

    tasks = @manager.enqueue_batch(tasks_data)

    assert_equal 3, tasks.size
    tasks.each do |task|
      assert task.persisted?
    end
  end

  test "reprioritize_task should update priority" do
    task = AgentTask.create!(task_type: "test", priority: 5)

    result = @manager.reprioritize_task(task.id, 10)

    assert result
    task.reload
    assert_equal 10, task.priority
  end

  test "check_deadlines should find overdue tasks" do
    AgentTask.create!(task_type: "test1", deadline: 1.hour.ago, status: "pending")
    AgentTask.create!(task_type: "test2", deadline: 1.hour.from_now, status: "pending")

    count = @manager.check_deadlines

    assert_equal 1, count
  end

  test "queue_statistics should return stats" do
    AgentTask.create!(task_type: "test1", status: "pending", priority: 15)
    AgentTask.create!(task_type: "test2", status: "completed", priority: 5)
    AgentTask.create!(task_type: "test3", status: "failed", priority: 3)

    stats = @manager.queue_statistics

    assert stats[:total_tasks] >= 3
    assert stats[:by_priority][:high] >= 1
  end

  test "move_failed_to_dead_letter should move exhausted tasks" do
    task = AgentTask.create!(
      task_type: "test",
      status: "failed",
      retry_count: 3,
      max_retries: 3
    )

    count = @manager.move_failed_to_dead_letter

    assert_equal 1, count
    task.reload
    assert_equal "dead_letter", task.status
  end
end
