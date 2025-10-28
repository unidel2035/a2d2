require "test_helper"

class IntegrationTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      name: "Test User",
      email: "integration@example.com",
      password: "password123",
      role: :admin
    )
    @integration = Integration.create!(
      name: "Test API",
      integration_type: "rest_api",
      user: @user,
      status: :active,
      configuration: {
        base_url: "https://api.example.com",
        endpoints: { test: "/test" }
      },
      credentials: { token: "test_token" }
    )
  end

  test "should be valid with valid attributes" do
    assert @integration.valid?
  end

  test "should require name" do
    @integration.name = nil
    assert_not @integration.valid?
  end

  test "should validate integration type" do
    @integration.integration_type = "invalid_type"
    assert_not @integration.valid?
    assert_includes @integration.errors[:integration_type], "is not included in the list"
  end

  test "should log integration execution" do
    initial_count = @integration.integration_logs.count

    @integration.integration_logs.create!(
      operation: "test_operation",
      status: :success,
      request_data: { test: "data" },
      response_data: { result: "success" },
      duration: 0.5,
      executed_at: Time.current
    )

    assert_equal initial_count + 1, @integration.integration_logs.count
  end

  test "should calculate success rate" do
    # Create some logs
    3.times do
      @integration.integration_logs.create!(
        operation: "test",
        status: :success,
        executed_at: Time.current,
        duration: 0.1
      )
    end

    1.times do
      @integration.integration_logs.create!(
        operation: "test",
        status: :failed,
        executed_at: Time.current,
        duration: 0.1,
        error_message: "Test error"
      )
    end

    rate = @integration.success_rate
    assert_equal 75.0, rate
  end

  test "should scope active integrations" do
    active = @integration
    inactive = Integration.create!(
      name: "Inactive API",
      integration_type: "rest_api",
      user: @user,
      status: :inactive
    )

    assert_includes Integration.active_integrations, active
    assert_not_includes Integration.active_integrations, inactive
  end

  test "should return recent logs" do
    5.times do |i|
      @integration.integration_logs.create!(
        operation: "test_#{i}",
        status: :success,
        executed_at: i.hours.ago,
        duration: 0.1
      )
    end

    recent = @integration.recent_logs(limit: 3)
    assert_equal 3, recent.count
  end
end
