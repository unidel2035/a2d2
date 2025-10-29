require "test_helper"

class RobotsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @robot = Robot.create!(
      serial_number: "TEST-001",
      manufacturer: "Test Manufacturer",
      model: "Test Model",
      status: :active
    )
  end

  test "should get index" do
    get robots_url
    assert_response :success
  end

  test "should get index with status filter" do
    get robots_url, params: { status: "active" }
    assert_response :success
  end

  test "should get index with manufacturer filter" do
    get robots_url, params: { manufacturer: "Test Manufacturer" }
    assert_response :success
  end

  test "should get index with search" do
    get robots_url, params: { search: "TEST" }
    assert_response :success
  end

  test "should get new" do
    get new_robot_url
    assert_response :success
  end

  test "should create robot" do
    assert_difference('Robot.count') do
      post robots_url, params: {
        robot: {
          serial_number: "TEST-002",
          manufacturer: "New Manufacturer",
          model: "New Model"
        }
      }
    end

    assert_redirected_to robots_url
  end

  test "should not create robot with duplicate serial number" do
    assert_no_difference('Robot.count') do
      post robots_url, params: {
        robot: {
          serial_number: @robot.serial_number,
          manufacturer: "New Manufacturer",
          model: "New Model"
        }
      }
    end
  end

  test "should show robot" do
    get robot_url(@robot)
    assert_response :success
  end

  test "should get edit" do
    get edit_robot_url(@robot)
    assert_response :success
  end

  test "should update robot" do
    patch robot_url(@robot), params: {
      robot: {
        manufacturer: "Updated Manufacturer"
      }
    }
    assert_redirected_to robot_url(@robot)

    @robot.reload
    assert_equal "Updated Manufacturer", @robot.manufacturer
  end

  test "should destroy robot" do
    assert_difference('Robot.count', -1) do
      delete robot_url(@robot)
    end

    assert_redirected_to robots_url
  end
end
