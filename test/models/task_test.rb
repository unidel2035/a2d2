require "test_helper"

class TaskTest < ActiveSupport::TestCase
  def setup
    @user = create(:user)
    @robot = create(:robot)
    @task = create(:task, robot: @robot, operator: @user)
  end

  test "should be valid with required attributes" do
    assert @task.valid?
  end

  test "should require task_number" do
    @task.task_number = nil
    @task.valid? # trigger before_validation callback
    assert_not_nil @task.task_number
  end

  test "should auto-generate task_number on create" do
    new_task = Task.create!(robot: @robot, status: :planned)
    assert_not_nil new_task.task_number
    assert_match(/^TSK-\d{8}-[A-F0-9]{8}$/, new_task.task_number)
  end

  test "should enforce unique task_number" do
    duplicate_task = build(:task, robot: @robot, task_number: @task.task_number)
    assert_not duplicate_task.valid?
    assert_includes duplicate_task.errors[:task_number], "has already been taken"
  end

  test "should require status" do
    @task.status = nil
    assert_not @task.valid?
    assert_includes @task.errors[:status], "can't be blank"
  end

  test "should have valid status enum values" do
    assert_equal :planned, @task.status.to_sym

    @task.status = :in_progress
    assert @task.in_progress?

    @task.status = :completed
    assert @task.completed?

    @task.status = :cancelled
    assert @task.cancelled?
  end

  test "start! should transition to in_progress and set actual_start" do
    assert @task.planned?
    @task.start!

    assert @task.in_progress?
    assert_not_nil @task.actual_start
    assert_in_delta Time.current, @task.actual_start, 1.second
  end

  test "complete! should transition to completed and set actual_end" do
    @task.start!
    @task.complete!

    assert @task.completed?
    assert_not_nil @task.actual_end
    assert_not_nil @task.duration
    assert_in_delta Time.current, @task.actual_end, 1.second
  end

  test "cancel! should transition to cancelled" do
    @task.cancel!
    assert @task.cancelled?
  end

  test "overdue? should return true for overdue planned tasks" do
    @task.update!(status: :planned, planned_date: 1.day.ago)
    assert @task.overdue?
  end

  test "overdue? should return false for future planned tasks" do
    @task.update!(status: :planned, planned_date: 1.day.from_now)
    assert_not @task.overdue?
  end

  test "overdue? should return false for non-planned tasks" do
    @task.update!(status: :in_progress, planned_date: 1.day.ago)
    assert_not @task.overdue?
  end

  test "calculate_duration should return duration in minutes" do
    start_time = 2.hours.ago
    end_time = Time.current
    @task.update!(actual_start: start_time, actual_end: end_time)

    expected_duration = ((end_time - start_time) / 60).to_i
    assert_equal expected_duration, @task.calculate_duration
  end

  test "calculate_duration should return nil without actual_start" do
    @task.update!(actual_start: nil, actual_end: Time.current)
    assert_nil @task.calculate_duration
  end

  test "calculate_duration should return nil without actual_end" do
    @task.update!(actual_start: Time.current, actual_end: nil)
    assert_nil @task.calculate_duration
  end

  test "create_inspection_report should create associated report" do
    assert_difference "@task.inspection_report", from: nil do
      report = @task.create_inspection_report(findings: "All systems operational")
      assert_not_nil report
      assert_not_nil report.report_number
      assert_match(/^RPT-\d{8}-[A-F0-9]{8}$/, report.report_number)
    end
  end

  test "scope recent should order by created_at desc" do
    old_task = create(:task, robot: @robot, created_at: 2.days.ago)
    new_task = create(:task, robot: @robot, created_at: 1.day.ago)

    tasks = Task.recent.limit(2)
    assert_equal new_task, tasks.first
    assert_equal old_task, tasks.second
  end

  test "scope upcoming should return future planned tasks" do
    upcoming_task = create(:task, robot: @robot, status: :planned, planned_date: 1.day.from_now)
    create(:task, robot: @robot, status: :planned, planned_date: 1.day.ago)

    assert_includes Task.upcoming, upcoming_task
  end

  test "scope overdue should return past planned tasks" do
    overdue_task = create(:task, robot: @robot, status: :planned, planned_date: 1.day.ago)
    create(:task, robot: @robot, status: :planned, planned_date: 1.day.from_now)

    assert_includes Task.overdue, overdue_task
  end

  test "scope completed_in_range should return completed tasks in date range" do
    start_date = 2.days.ago
    end_date = Time.current
    completed_task = create(:task, robot: @robot, status: :completed, actual_end: 1.day.ago)
    create(:task, robot: @robot, status: :completed, actual_end: 3.days.ago)

    tasks = Task.completed_in_range(start_date, end_date)
    assert_includes tasks, completed_task
  end

  test "should update robot stats when task is completed" do
    @task.start!
    initial_tasks = @robot.total_tasks || 0

    @task.complete!
    @robot.reload

    assert_equal initial_tasks + 1, @robot.total_tasks
  end

  test "should have telemetry_data association" do
    assert_respond_to @task, :telemetry_data
  end

  test "should destroy associated telemetry_data when destroyed" do
    telemetry = create(:telemetry_data, task: @task, robot: @robot)

    assert_difference "TelemetryData.count", -1 do
      @task.destroy
    end
  end
end
