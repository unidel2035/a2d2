require "test_helper"

class RobotTest < ActiveSupport::TestCase
  def setup
    @robot = Robot.create!(
      manufacturer: "TestCorp",
      model: "RB-100",
      serial_number: "SN123456",
      registration_number: "REG-001",
      status: :active,
      specifications: { type: "inspection" },
      capabilities: { autonomous: true }
    )
  end

  test "should be valid with valid attributes" do
    assert @robot.valid?
  end

  test "should require unique serial number" do
    duplicate = Robot.new(
      manufacturer: "TestCorp",
      model: "RB-200",
      serial_number: "SN123456",
      status: :active
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:serial_number], "has already been taken"
  end

  test "should register robot" do
    new_robot = Robot.register(
      manufacturer: "NewCorp",
      model: "RB-300",
      serial_number: "SN789",
      status: :active
    )

    assert new_robot.persisted?
    assert_equal :active, new_robot.status.to_sym
  end

  test "should record telemetry" do
    telemetry = @robot.record_telemetry(
      location: "Test Location",
      latitude: 55.7558,
      longitude: 37.6173,
      altitude: 100.5,
      sensors: { temperature: 25.5 },
      operation_hours: 2.5
    )

    assert telemetry.persisted?
    assert_equal 2.5, @robot.reload.total_operation_hours
  end

  test "should schedule maintenance" do
    user = User.create!(name: "Tech", email: "tech@example.com", password: "password123", role: :technician)

    maintenance = @robot.schedule_maintenance(
      scheduled_date: 1.month.from_now,
      maintenance_type: :routine,
      technician: user
    )

    assert maintenance.persisted?
    assert_equal :scheduled, maintenance.status.to_sym
  end

  test "should detect if maintenance needed" do
    # Robot with recent maintenance
    @robot.update!(last_maintenance_date: 1.month.ago)
    assert_not @robot.needs_maintenance?

    # Robot with old maintenance
    @robot.update!(last_maintenance_date: 7.months.ago)
    assert @robot.needs_maintenance?

    # Robot with high operation hours
    @robot.update!(
      last_maintenance_date: 1.month.ago,
      total_operation_hours: 600
    )
    @robot.maintenance_records.create!(
      scheduled_date: 1.month.ago,
      maintenance_type: :routine,
      status: :completed,
      completed_date: 1.month.ago,
      operation_hours_at_maintenance: 50
    )
    assert @robot.needs_maintenance?
  end

  test "should calculate utilization rate" do
    user = User.create!(name: "Operator", email: "op@example.com", password: "password123", role: :operator)

    # Create completed task with 120 minutes duration
    @robot.tasks.create!(
      task_number: "TSK-001",
      status: :completed,
      duration: 120,
      operator: user,
      actual_start: 1.day.ago,
      actual_end: 1.day.ago + 2.hours
    )

    rate = @robot.utilization_rate(period: 30.days)
    assert rate >= 0
  end

  test "should scope active robots" do
    active = @robot
    retired = Robot.create!(
      manufacturer: "OldCorp",
      model: "RB-OLD",
      serial_number: "SN-OLD",
      status: :retired
    )

    assert_includes Robot.active_robots, active
    assert_not_includes Robot.active_robots, retired
  end
end
