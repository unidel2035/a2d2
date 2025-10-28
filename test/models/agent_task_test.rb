require "test_helper"

class AgentTaskTest < ActiveSupport::TestCase
  def setup
    @task = AgentTask.new(
      task_type: "test_task",
      status: "pending",
      priority: 5,
      input_data: { test: "data" }
    )
  end

  test "valid task" do
    assert @task.valid?
  end

  test "requires task_type" do
    @task.task_type = nil
    assert_not @task.valid?
  end

  test "validates status inclusion" do
    @task.status = "invalid"
    assert_not @task.valid?
  end

  test "validates priority range" do
    @task.priority = 0
    assert_not @task.valid?

    @task.priority = 11
    assert_not @task.valid?

    @task.priority = 5
    assert @task.valid?
  end

  test "start! updates status and started_at" do
    @task.save!
    @task.start!
    assert_equal "processing", @task.status
    assert_not_nil @task.started_at
  end

  test "complete! updates status and output" do
    @task.save!
    @task.start!
    output = { result: "success" }
    @task.complete!(output)
    assert_equal "completed", @task.status
    assert_equal output, @task.output_data
    assert_not_nil @task.completed_at
  end

  test "fail! updates status and error message" do
    @task.save!
    @task.start!
    @task.fail!("Test error")
    assert_equal "failed", @task.status
    assert_equal "Test error", @task.error_message
    assert_not_nil @task.completed_at
  end

  test "overdue? returns true for past deadline" do
    @task.deadline_at = 1.hour.ago
    assert @task.overdue?
  end

  test "overdue? returns false for completed tasks" do
    @task.deadline_at = 1.hour.ago
    @task.status = "completed"
    assert_not @task.overdue?
  end

  test "processing_time calculates duration" do
    @task.started_at = Time.current - 10.seconds
    @task.completed_at = Time.current
    assert_in_delta 10, @task.processing_time, 1
  end
end
