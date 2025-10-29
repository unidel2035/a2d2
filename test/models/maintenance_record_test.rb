require "test_helper"

class MaintenanceRecordTest < ActiveSupport::TestCase
  def setup
    @robot = robots(:one)
    @technician = users(:technician)
    @maintenance_record = MaintenanceRecord.create!(
      robot: @robot,
      technician: @technician,
      scheduled_date: 1.week.from_now,
      maintenance_type: :routine,
      status: :scheduled,
      operation_hours_at_maintenance: 120.5
    )
  end

  test "should be valid with valid attributes" do
    assert @maintenance_record.valid?
  end

  test "should require scheduled_date" do
    @maintenance_record.scheduled_date = nil
    assert_not @maintenance_record.valid?
    assert_includes @maintenance_record.errors[:scheduled_date], "can't be blank"
  end

  test "should require maintenance_type" do
    @maintenance_record.maintenance_type = nil
    assert_not @maintenance_record.valid?
  end

  test "should require status" do
    @maintenance_record.status = nil
    assert_not @maintenance_record.valid?
  end

  test "should belong to robot" do
    assert_equal @robot, @maintenance_record.robot
  end

  test "should belong to technician" do
    assert_equal @technician, @maintenance_record.technician
  end

  test "should allow nil technician" do
    record = MaintenanceRecord.new(
      robot: @robot,
      scheduled_date: 1.week.from_now,
      maintenance_type: :routine,
      status: :scheduled
    )
    assert record.valid?
  end

  # Тесты scopes
  test "should scope upcoming maintenance" do
    upcoming = MaintenanceRecord.create!(
      robot: @robot,
      scheduled_date: 1.week.from_now,
      maintenance_type: :routine,
      status: :scheduled
    )
    past = MaintenanceRecord.create!(
      robot: @robot,
      scheduled_date: 1.week.ago,
      maintenance_type: :routine,
      status: :scheduled
    )

    assert_includes MaintenanceRecord.upcoming, upcoming
    assert_not_includes MaintenanceRecord.upcoming, past
  end

  test "should scope overdue maintenance" do
    overdue = MaintenanceRecord.create!(
      robot: @robot,
      scheduled_date: 1.day.ago,
      maintenance_type: :routine,
      status: :scheduled
    )
    upcoming = MaintenanceRecord.create!(
      robot: @robot,
      scheduled_date: 1.week.from_now,
      maintenance_type: :routine,
      status: :scheduled
    )

    assert_includes MaintenanceRecord.overdue, overdue
    assert_not_includes MaintenanceRecord.overdue, upcoming
  end

  test "should scope completed recently" do
    recent = MaintenanceRecord.create!(
      robot: @robot,
      scheduled_date: 1.week.ago,
      maintenance_type: :routine,
      status: :completed,
      completed_date: 5.days.ago
    )
    old = MaintenanceRecord.create!(
      robot: @robot,
      scheduled_date: 2.months.ago,
      maintenance_type: :routine,
      status: :completed,
      completed_date: 2.months.ago
    )

    assert_includes MaintenanceRecord.completed_recently, recent
    assert_not_includes MaintenanceRecord.completed_recently, old
  end

  # Тесты методов состояния
  test "should start maintenance" do
    @maintenance_record.start!
    assert @maintenance_record.in_progress?
  end

  test "should complete maintenance" do
    @maintenance_record.complete!(
      description: "All systems checked",
      cost: 5000.0,
      replaced_components: ["filter", "battery"]
    )

    assert @maintenance_record.completed?
    assert_equal Date.current, @maintenance_record.completed_date
    assert_equal "All systems checked", @maintenance_record.description
    assert_equal 5000.0, @maintenance_record.cost
    assert_equal ["filter", "battery"], @maintenance_record.replaced_components
    assert_not_nil @maintenance_record.next_maintenance_date
  end

  test "should update robot status when completing maintenance" do
    @robot.update!(status: :maintenance)
    @maintenance_record.complete!

    assert_equal :active, @robot.reload.status.to_sym
  end

  test "should update robot last_maintenance_date when completed" do
    @maintenance_record.complete!

    assert_equal Date.current, @robot.reload.last_maintenance_date
  end

  test "should cancel maintenance" do
    @maintenance_record.cancel!
    assert @maintenance_record.cancelled?
  end

  test "should detect overdue maintenance" do
    overdue_record = MaintenanceRecord.create!(
      robot: @robot,
      scheduled_date: 1.day.ago,
      maintenance_type: :routine,
      status: :scheduled
    )
    assert overdue_record.overdue?

    upcoming_record = MaintenanceRecord.create!(
      robot: @robot,
      scheduled_date: 1.week.from_now,
      maintenance_type: :routine,
      status: :scheduled
    )
    assert_not upcoming_record.overdue?
  end

  test "should calculate next maintenance date for routine" do
    @maintenance_record.update!(maintenance_type: :routine)
    @maintenance_record.complete!

    expected_date = @maintenance_record.scheduled_date + 6.months
    assert_equal expected_date, @maintenance_record.next_maintenance_date
  end

  test "should calculate next maintenance date for repair" do
    @maintenance_record.update!(maintenance_type: :repair)
    @maintenance_record.complete!

    expected_date = @maintenance_record.scheduled_date + 3.months
    assert_equal expected_date, @maintenance_record.next_maintenance_date
  end

  test "should calculate next maintenance date for component_replacement" do
    @maintenance_record.update!(maintenance_type: :component_replacement)
    @maintenance_record.complete!

    expected_date = @maintenance_record.scheduled_date + 6.months
    assert_equal expected_date, @maintenance_record.next_maintenance_date
  end
end
