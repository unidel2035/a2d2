require "test_helper"

class Api::V1::MaintenanceRecordsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @robot = FactoryBot.create(:robot)
    @technician = FactoryBot.create(:user, :technician)
    @maintenance_record = FactoryBot.create(:maintenance_record, robot: @robot, technician: @technician)
  end

  test "should get index" do
    get api_v1_maintenance_records_url
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response.key?("maintenance_records")
    assert json_response.key?("total")
    assert_equal 1, json_response["maintenance_records"].length
  end

  test "should filter maintenance records by robot_id" do
    other_robot = FactoryBot.create(:robot)
    FactoryBot.create(:maintenance_record, robot: other_robot)

    get api_v1_maintenance_records_url, params: { robot_id: @robot.id }
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 1, json_response["maintenance_records"].length
    assert_equal @robot.id, json_response["maintenance_records"][0]["robot_id"]
  end

  test "should filter maintenance records by status" do
    FactoryBot.create(:maintenance_record, :completed, robot: @robot)
    FactoryBot.create(:maintenance_record, :in_progress, robot: @robot)

    get api_v1_maintenance_records_url, params: { status: "scheduled" }
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 1, json_response["maintenance_records"].length
    assert_equal "scheduled", json_response["maintenance_records"][0]["status"]
  end

  test "should filter maintenance records by maintenance_type" do
    FactoryBot.create(:maintenance_record, :repair, robot: @robot)
    FactoryBot.create(:maintenance_record, :component_replacement, robot: @robot)

    get api_v1_maintenance_records_url, params: { maintenance_type: "routine" }
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 1, json_response["maintenance_records"].length
    assert_equal "routine", json_response["maintenance_records"][0]["maintenance_type"]
  end

  test "should support pagination" do
    9.times { FactoryBot.create(:maintenance_record, robot: @robot) }

    get api_v1_maintenance_records_url, params: { page: 1, per_page: 5 }
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 5, json_response["maintenance_records"].length
    assert_equal 1, json_response["page"]
    assert_equal 5, json_response["per_page"]
    assert_equal 10, json_response["total"]
  end

  test "should show maintenance record" do
    get api_v1_maintenance_record_url(@maintenance_record)
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @maintenance_record.id, json_response["id"]
    assert_equal @maintenance_record.robot_id, json_response["robot_id"]
    assert json_response.key?("technician_id")
    assert json_response.key?("description")
    assert json_response.key?("overdue")
  end

  test "should return 404 for non-existent maintenance record" do
    get api_v1_maintenance_record_url(id: 99999)
    assert_response :not_found

    json_response = JSON.parse(response.body)
    assert_equal "Maintenance record not found", json_response["error"]
  end

  test "should create maintenance record" do
    assert_difference("MaintenanceRecord.count") do
      post api_v1_maintenance_records_url, params: {
        robot_id: @robot.id,
        technician_id: @technician.id,
        scheduled_date: 2.weeks.from_now.to_date,
        maintenance_type: "routine",
        status: "scheduled",
        description: "Scheduled maintenance"
      }
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal @robot.id, json_response["robot_id"]
    assert_equal "routine", json_response["maintenance_type"]
  end

  test "should not create maintenance record without required fields" do
    post api_v1_maintenance_records_url, params: {
      robot_id: @robot.id,
      description: "Missing required fields"
    }

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert json_response.key?("errors")
  end

  test "should not create maintenance record with invalid robot_id" do
    post api_v1_maintenance_records_url, params: {
      robot_id: 99999,
      scheduled_date: 1.week.from_now.to_date,
      maintenance_type: "routine",
      status: "scheduled"
    }

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert json_response.key?("errors")
  end

  test "should update maintenance record" do
    patch api_v1_maintenance_record_url(@maintenance_record), params: {
      status: "in_progress",
      description: "Work in progress"
    }

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "in_progress", json_response["status"]

    @maintenance_record.reload
    assert_equal "in_progress", @maintenance_record.status
    assert_equal "Work in progress", @maintenance_record.description
  end

  test "should update maintenance record to completed" do
    patch api_v1_maintenance_record_url(@maintenance_record), params: {
      status: "completed",
      completed_date: Date.current,
      cost: 2000.00,
      description: "Maintenance completed successfully"
    }

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "completed", json_response["status"]

    @maintenance_record.reload
    assert_equal "completed", @maintenance_record.status
    assert_equal 2000.00, @maintenance_record.cost
  end

  test "should not update maintenance record with invalid data" do
    patch api_v1_maintenance_record_url(@maintenance_record), params: {
      scheduled_date: nil
    }

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert json_response.key?("errors")
  end

  test "should destroy maintenance record" do
    assert_difference("MaintenanceRecord.count", -1) do
      delete api_v1_maintenance_record_url(@maintenance_record)
    end

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "Maintenance record deleted successfully", json_response["message"]
  end

  test "should return 404 when deleting non-existent maintenance record" do
    delete api_v1_maintenance_record_url(id: 99999)
    assert_response :not_found

    json_response = JSON.parse(response.body)
    assert_equal "Maintenance record not found", json_response["error"]
  end
end
