require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @robot = Robot.create!(
      serial_number: "TEST-001",
      manufacturer: "Test Manufacturer",
      model: "Test Model",
      status: :active
    )

    @task = @robot.robot_tasks.create!(
      task_number: "TSK-20241029-TEST",
      planned_date: Time.current + 1.day,
      goal: "Test goal",
      status: :planned
    )
  end

  test "should get index" do
    get tasks_url
    assert_response :success
  end

  test "should get index with status filter" do
    get tasks_url, params: { status: "planned" }
    assert_response :success
  end

  test "should get index with robot filter" do
    get tasks_url, params: { robot_id: @robot.id }
    assert_response :success
  end

  test "should show task" do
    get task_url(@task)
    assert_response :success
  end
end
