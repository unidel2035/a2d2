require "test_helper"

class AgentTest < ActiveSupport::TestCase
  def setup
    @agent = Agent.new(
      name: "Test Agent",
      type: "Agent",
      status: "idle",
      capabilities: { test: true }
    )
  end

  test "valid agent" do
    assert @agent.valid?
  end

  test "requires name" do
    @agent.name = nil
    assert_not @agent.valid?
  end

  test "requires type" do
    @agent.type = nil
    assert_not @agent.valid?
  end

  test "validates status inclusion" do
    @agent.status = "invalid_status"
    assert_not @agent.valid?
  end

  test "heartbeat updates timestamp and status" do
    @agent.save!
    @agent.heartbeat!
    assert_not_nil @agent.last_heartbeat_at
    assert_equal "idle", @agent.status
  end

  test "online? returns true for recent heartbeat" do
    @agent.last_heartbeat_at = 1.minute.ago
    assert @agent.online?
  end

  test "online? returns false for old heartbeat" do
    @agent.last_heartbeat_at = 10.minutes.ago
    assert_not @agent.online?
  end

  test "can_handle? checks capabilities" do
    assert @agent.can_handle?(:test)
    assert_not @agent.can_handle?(:missing)
  end

  test "report_status returns status hash" do
    status = @agent.report_status
    assert_equal @agent.name, status[:name]
    assert_equal @agent.type, status[:type]
    assert_equal @agent.capabilities, status[:capabilities]
  end
end
