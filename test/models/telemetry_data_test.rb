require "test_helper"

class TelemetryDataTest < ActiveSupport::TestCase
  def setup
    @robot = create(:robot)
    @task = create(:task, robot: @robot)
    @telemetry = create(:telemetry_data, robot: @robot, task: @task)
  end

  test "should be valid with required attributes" do
    assert @telemetry.valid?
  end

  test "should require recorded_at" do
    @telemetry.recorded_at = nil
    assert_not @telemetry.valid?
    assert_includes @telemetry.errors[:recorded_at], "can't be blank"
  end

  test "should belong to robot" do
    assert_respond_to @telemetry, :robot
    assert_equal @robot, @telemetry.robot
  end

  test "should optionally belong to task" do
    assert_respond_to @telemetry, :task
    @telemetry.task = nil
    assert @telemetry.valid?
  end

  test "record should create telemetry with params" do
    params = {
      recorded_at: Time.current,
      data: { "temperature" => 25.5, "humidity" => 60 },
      location: "Building A",
      latitude: 40.7128,
      longitude: -74.0060,
      altitude: 10.5,
      sensors: { "battery" => 85 }
    }

    telemetry = TelemetryData.record(@robot.id, params)

    assert telemetry.persisted?
    assert_equal params[:location], telemetry.location
    assert_equal params[:latitude], telemetry.latitude
    assert_equal params[:longitude], telemetry.longitude
  end

  test "record should use current time if recorded_at not provided" do
    telemetry = TelemetryData.record(@robot.id, {})
    assert_not_nil telemetry.recorded_at
    assert_in_delta Time.current, telemetry.recorded_at, 1.second
  end

  test "has_location? should return true when lat and lon present" do
    @telemetry.latitude = 40.7128
    @telemetry.longitude = -74.0060
    assert @telemetry.has_location?
  end

  test "has_location? should return false when lat or lon missing" do
    @telemetry.latitude = nil
    @telemetry.longitude = -74.0060
    assert_not @telemetry.has_location?

    @telemetry.latitude = 40.7128
    @telemetry.longitude = nil
    assert_not @telemetry.has_location?
  end

  test "distance_from should calculate distance using Haversine formula" do
    # New York coordinates
    telemetry1 = create(:telemetry_data, robot: @robot, latitude: 40.7128, longitude: -74.0060)
    # Los Angeles coordinates (approximately 3935 km away)
    telemetry2 = create(:telemetry_data, robot: @robot, latitude: 34.0522, longitude: -118.2437)

    distance = telemetry1.distance_from(telemetry2)
    assert_not_nil distance
    # Allow for some variance in the calculation
    assert_in_delta 3935, distance, 100 # within 100km of expected distance
  end

  test "distance_from should return nil if either location missing" do
    telemetry1 = create(:telemetry_data, robot: @robot, latitude: nil, longitude: nil)
    telemetry2 = create(:telemetry_data, robot: @robot, latitude: 40.7128, longitude: -74.0060)

    assert_nil telemetry1.distance_from(telemetry2)
  end

  test "scope recent should order by recorded_at desc" do
    old_telemetry = create(:telemetry_data, robot: @robot, recorded_at: 2.hours.ago)
    new_telemetry = create(:telemetry_data, robot: @robot, recorded_at: 1.hour.ago)

    recent = TelemetryData.recent.limit(2)
    assert_equal new_telemetry, recent.first
    assert_equal old_telemetry, recent.second
  end

  test "scope for_robot should filter by robot_id" do
    other_robot = create(:robot)
    other_telemetry = create(:telemetry_data, robot: other_robot)

    telemetries = TelemetryData.for_robot(@robot.id)
    assert_includes telemetries, @telemetry
    assert_not_includes telemetries, other_telemetry
  end

  test "scope in_range should filter by time range" do
    start_time = 2.hours.ago
    end_time = Time.current
    in_range_telemetry = create(:telemetry_data, robot: @robot, recorded_at: 1.hour.ago)
    out_of_range_telemetry = create(:telemetry_data, robot: @robot, recorded_at: 3.hours.ago)

    telemetries = TelemetryData.in_range(start_time, end_time)
    assert_includes telemetries, in_range_telemetry
    assert_not_includes telemetries, out_of_range_telemetry
  end

  test "scope with_location should filter telemetry with coordinates" do
    with_location = create(:telemetry_data, robot: @robot, latitude: 40.7128, longitude: -74.0060)
    without_location = create(:telemetry_data, robot: @robot, latitude: nil, longitude: nil)

    telemetries = TelemetryData.with_location
    assert_includes telemetries, with_location
    assert_not_includes telemetries, without_location
  end

  test "aggregate_metrics should calculate statistics" do
    # Create telemetry data
    3.times do |i|
      create(:telemetry_data,
        robot: @robot,
        recorded_at: (i + 1).hours.ago,
        altitude: 10.0 + i * 5
      )
    end

    metrics = TelemetryData.aggregate_metrics(@robot.id, period: 24.hours)

    assert_not_nil metrics[:count]
    assert_operator metrics[:count], :>=, 3
    assert_not_nil metrics[:avg_altitude]
    assert_not_nil metrics[:max_altitude]
    assert_not_nil metrics[:min_altitude]
  end

  test "calculate_total_distance should sum distances between points" do
    # Create a path of telemetry points
    telemetries = [
      create(:telemetry_data, robot: @robot, latitude: 40.7128, longitude: -74.0060, recorded_at: 3.hours.ago),
      create(:telemetry_data, robot: @robot, latitude: 40.7580, longitude: -73.9855, recorded_at: 2.hours.ago),
      create(:telemetry_data, robot: @robot, latitude: 40.7589, longitude: -73.9851, recorded_at: 1.hour.ago)
    ]

    total_distance = TelemetryData.calculate_total_distance(telemetries)
    assert_not_nil total_distance
    assert_operator total_distance, :>, 0
  end
end
