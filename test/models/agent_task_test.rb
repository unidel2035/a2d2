require "test_helper"

class AgentTaskTest < ActiveSupport::TestCase
  def setup
    @agent = Agent.create!(
      name: "test-agent",
      agent_type: "test",
      status: "idle"
    )

    @task = AgentTask.create!(
      task_type: "data_analysis",
      payload: { data: "test" },
      priority: 5
    )
  end

  test "should create task with valid attributes" do
    assert @task.persisted?
    assert_equal "data_analysis", @task.task_type
    assert_equal "pending", @task.status
    assert_equal 5, @task.priority
  end

  test "should require task_type" do
    task = AgentTask.new
    assert_not task.valid?
    assert_includes task.errors[:task_type], "can't be blank"
  end

  test "assign_to! should assign task to agent" do
    result = @task.assign_to!(@agent)

    assert result
    assert_equal "assigned", @task.status
    assert_equal @agent, @task.agent
    assert_not_nil @task.started_at
  end

  test "start! should change status to running" do
    @task.assign_to!(@agent)
    @task.start!

    assert_equal "running", @task.status
  end

  test "complete! should set status and result" do
    @task.assign_to!(@agent)
    @task.start!

    result_data = { output: "success" }
    @task.complete!(result_data)

    assert_equal "completed", @task.status
    assert_equal result_data, @task.result
    assert_not_nil @task.completed_at
  end

  test "fail! should set status and error message" do
    @task.assign_to!(@agent)
    @task.start!

    @task.fail!("Test error")

    assert_equal "failed", @task.status
    assert_equal "Test error", @task.error_message
    assert_not_nil @task.completed_at
  end

  test "retry! should reset task for retry" do
    @task.assign_to!(@agent)
    @task.start!
    @task.fail!("Error")

    result = @task.retry!

    assert result
    assert_equal "pending", @task.status
    assert_equal 1, @task.retry_count
    assert_nil @task.agent
  end

  test "retry! should not retry if max retries exceeded" do
    @task.update!(retry_count: 3, max_retries: 3, status: "failed")

    result = @task.retry!

    assert_not result
  end

  test "move_to_dead_letter! should change status" do
    @task.move_to_dead_letter!

    assert_equal "dead_letter", @task.status
    assert_not_nil @task.completed_at
  end

  test "duration should calculate correctly" do
    start_time = Time.current
    end_time = start_time + 10.seconds

    @task.update!(started_at: start_time, completed_at: end_time)

    assert_in_delta 10.0, @task.duration, 0.1
  end

  test "scopes should filter correctly" do
    AgentTask.create!(task_type: "test1", status: "pending")
    AgentTask.create!(task_type: "test2", status: "completed")
    AgentTask.create!(task_type: "test3", status: "failed")

    assert_equal 2, AgentTask.pending.count
    assert_equal 1, AgentTask.completed.count
    assert_equal 1, AgentTask.failed.count
  end
end
