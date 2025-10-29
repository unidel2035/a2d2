require "test_helper"

class Api::V1::RobotsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @robot = FactoryBot.create(:robot)
  end

  test "should get index" do
    get api_v1_robots_url
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response.key?("robots")
    assert json_response.key?("total")
    assert_equal 1, json_response["robots"].length
  end

  test "should filter robots by status" do
    FactoryBot.create(:robot, :maintenance)
    FactoryBot.create(:robot, :repair)

    get api_v1_robots_url, params: { status: "active" }
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 1, json_response["robots"].length
    assert_equal "active", json_response["robots"][0]["status"]
  end

  test "should filter robots by manufacturer" do
    FactoryBot.create(:robot, manufacturer: "Other Corp")

    get api_v1_robots_url, params: { manufacturer: "AgriTech Industries" }
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 1, json_response["robots"].length
    assert_equal "AgriTech Industries", json_response["robots"][0]["manufacturer"]
  end

  test "should support pagination" do
    9.times { FactoryBot.create(:robot) }

    get api_v1_robots_url, params: { page: 1, per_page: 5 }
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 5, json_response["robots"].length
    assert_equal 1, json_response["page"]
    assert_equal 5, json_response["per_page"]
    assert_equal 10, json_response["total"]
  end

  test "should show robot" do
    get api_v1_robot_url(@robot)
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @robot.id, json_response["id"]
    assert_equal @robot.serial_number, json_response["serial_number"]
    assert json_response.key?("needs_maintenance")
    assert json_response.key?("utilization_rate")
  end

  test "should return 404 for non-existent robot" do
    get api_v1_robot_url(id: 99999)
    assert_response :not_found

    json_response = JSON.parse(response.body)
    assert_equal "Robot not found", json_response["error"]
  end

  test "should create robot" do
    assert_difference("Robot.count") do
      post api_v1_robots_url, params: {
        serial_number: "ROBOT-9999",
        model: "AgriBot-X2",
        manufacturer: "AgriTech Industries",
        manufacture_date: "2024-01-01",
        location: "Field B"
      }
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "ROBOT-9999", json_response["serial_number"]
  end

  test "should not create robot with duplicate serial number" do
    post api_v1_robots_url, params: {
      serial_number: @robot.serial_number,
      model: "AgriBot-X2",
      manufacturer: "AgriTech Industries"
    }

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert json_response.key?("error")
  end

  test "should not create robot without serial number" do
    post api_v1_robots_url, params: {
      model: "AgriBot-X2",
      manufacturer: "AgriTech Industries"
    }

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert json_response.key?("error")
  end

  test "should update robot" do
    patch api_v1_robot_url(@robot), params: {
      location: "Field C",
      status: "maintenance"
    }

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "Field C", json_response["location"]
    assert_equal "maintenance", json_response["status"]

    @robot.reload
    assert_equal "Field C", @robot.location
    assert_equal "maintenance", @robot.status
  end

  test "should not update robot with invalid data" do
    patch api_v1_robot_url(@robot), params: {
      serial_number: ""
    }

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert json_response.key?("errors")
  end

  test "should destroy robot" do
    assert_difference("Robot.count", -1) do
      delete api_v1_robot_url(@robot)
    end

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "Robot deleted successfully", json_response["message"]
  end

  test "should return 404 when deleting non-existent robot" do
    delete api_v1_robot_url(id: 99999)
    assert_response :not_found

    json_response = JSON.parse(response.body)
    assert_equal "Robot not found", json_response["error"]
  end
end
