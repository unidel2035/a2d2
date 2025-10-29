require "test_helper"

class MaintenanceRecordsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @robot = Robot.create!(
      serial_number: "TEST-001",
      manufacturer: "Test Manufacturer",
      model: "Test Model",
      status: :active
    )

    @maintenance_record = @robot.maintenance_records.create!(
      scheduled_date: Date.current + 7.days,
      maintenance_type: :routine,
      status: :scheduled
    )
  end

  test "should get index" do
    get maintenance_records_url
    assert_response :success
  end

  test "should get index with status filter" do
    get maintenance_records_url, params: { status: "scheduled" }
    assert_response :success
  end

  test "should get index with robot filter" do
    get maintenance_records_url, params: { robot_id: @robot.id }
    assert_response :success
  end

  test "should show maintenance record" do
    get maintenance_record_url(@maintenance_record)
    assert_response :success
  end
end
