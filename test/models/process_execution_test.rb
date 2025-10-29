require "test_helper"

class ProcessExecutionTest < ActiveSupport::TestCase
  def setup
    @user = create(:user)
    @process = create(:process)
    @process_execution = create(:process_execution, process: @process, user: @user)
  end

  test "should be valid with required attributes" do
    assert @process_execution.valid?
  end

  test "should require status" do
    @process_execution.status = nil
    assert_not @process_execution.valid?
    assert_includes @process_execution.errors[:status], "can't be blank"
  end

  test "should have valid status enum values" do
    @process_execution.status = :pending
    assert @process_execution.pending?

    @process_execution.status = :running
    assert @process_execution.running?

    @process_execution.status = :completed
    assert @process_execution.completed?

    @process_execution.status = :failed
    assert @process_execution.failed?

    @process_execution.status = :cancelled
    assert @process_execution.cancelled?
  end

  test "should belong to process" do
    assert_respond_to @process_execution, :process
    assert_equal @process, @process_execution.process
  end

  test "should optionally belong to user" do
    assert_respond_to @process_execution, :user
    @process_execution.user = nil
    assert @process_execution.valid?
  end

  test "should have many process_step_executions" do
    assert_respond_to @process_execution, :process_step_executions
  end

  test "cancel! should set status to cancelled" do
    @process_execution.cancel!
    assert @process_execution.cancelled?
    assert_not_nil @process_execution.completed_at
  end

  test "duration should calculate time difference" do
    start_time = 2.hours.ago
    end_time = Time.current
    @process_execution.update!(started_at: start_time, completed_at: end_time)

    expected_duration = end_time - start_time
    assert_in_delta expected_duration, @process_execution.duration, 1.second
  end

  test "duration should use current time if not completed" do
    start_time = 1.hour.ago
    @process_execution.update!(started_at: start_time, completed_at: nil)

    expected_duration = Time.current - start_time
    assert_in_delta expected_duration, @process_execution.duration, 1.second
  end

  test "duration should return nil without started_at" do
    @process_execution.update!(started_at: nil)
    assert_nil @process_execution.duration
  end

  test "progress_percentage should return 0 for pending" do
    @process_execution.status = :pending
    assert_equal 0, @process_execution.progress_percentage
  end

  test "progress_percentage should return 100 for completed" do
    @process_execution.status = :completed
    assert_equal 100, @process_execution.progress_percentage
  end

  test "retry! should reset failed execution to pending" do
    @process_execution.update!(
      status: :failed,
      error_message: "Test error",
      started_at: 1.hour.ago,
      completed_at: Time.current
    )

    @process_execution.retry!

    assert @process_execution.pending?
    assert_nil @process_execution.error_message
    assert_nil @process_execution.started_at
    assert_nil @process_execution.completed_at
  end

  test "retry! should not work for non-failed executions" do
    @process_execution.status = :completed
    @process_execution.retry!
    assert @process_execution.completed?
  end

  test "scope recent should order by created_at desc" do
    old_execution = create(:process_execution, process: @process, created_at: 2.days.ago)
    new_execution = create(:process_execution, process: @process, created_at: 1.day.ago)

    executions = ProcessExecution.recent.limit(2)
    assert_equal new_execution, executions.first
    assert_equal old_execution, executions.second
  end

  test "scope active should return pending and running executions" do
    pending_exec = create(:process_execution, process: @process, status: :pending)
    running_exec = create(:process_execution, process: @process, status: :running)
    completed_exec = create(:process_execution, process: @process, status: :completed)

    active = ProcessExecution.active
    assert_includes active, pending_exec
    assert_includes active, running_exec
    assert_not_includes active, completed_exec
  end

  test "scope completed_recently should return recently completed executions" do
    recent_completed = create(:process_execution,
      process: @process,
      status: :completed,
      completed_at: 1.hour.ago
    )
    old_completed = create(:process_execution,
      process: @process,
      status: :completed,
      completed_at: 2.days.ago
    )

    recently_completed = ProcessExecution.completed_recently
    assert_includes recently_completed, recent_completed
    assert_not_includes recently_completed, old_completed
  end

  test "should destroy associated process_step_executions" do
    step = create(:process_step, process: @process)
    step_execution = create(:process_step_execution,
      process_execution: @process_execution,
      process_step: step
    )

    assert_difference "ProcessStepExecution.count", -1 do
      @process_execution.destroy
    end
  end
end
