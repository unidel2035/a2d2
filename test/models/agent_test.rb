require "test_helper"

class AgentTest < ActiveSupport::TestCase
  def setup
    @agent = Agent.create!(
      name: "test-agent",
      agent_type: "analyzer",
      capabilities: ["data_analysis", "pattern_recognition"],
      status: "idle"
    )
  end

  test "should create agent with valid attributes" do
    assert @agent.persisted?
    assert_equal "test-agent", @agent.name
    assert_equal "analyzer", @agent.agent_type
    assert_equal "idle", @agent.status
  end

  test "should require name" do
    agent = Agent.new(agent_type: "test")
    assert_not agent.valid?
    assert_includes agent.errors[:name], "can't be blank"
  end

  test "should require unique name" do
    duplicate = Agent.new(name: "test-agent", agent_type: "test")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "should create registry entry after creation" do
    assert_not_nil @agent.agent_registry_entry
    assert_equal "registered", @agent.agent_registry_entry.registration_status
  end

  test "activate! should change status to idle" do
    @agent.update!(status: "inactive")
    @agent.activate!

    assert_equal "idle", @agent.status
    assert_not_nil @agent.last_heartbeat
  end

  test "deactivate! should change status to inactive" do
    @agent.deactivate!
    assert_equal "inactive", @agent.status
  end

  test "mark_busy! should change status to busy" do
    @agent.mark_busy!
    assert_equal "busy", @agent.status
  end

  test "mark_idle! should change status to idle" do
    @agent.update!(status: "busy")
    @agent.mark_idle!
    assert_equal "idle", @agent.status
  end

  test "mark_failed! should decrease health score" do
    initial_score = @agent.health_score
    @agent.mark_failed!

    assert_equal "failed", @agent.status
    assert @agent.health_score < initial_score
  end

  test "heartbeat! should update last_heartbeat" do
    old_time = 1.hour.ago
    @agent.update!(last_heartbeat: old_time)

    @agent.heartbeat!

    assert @agent.last_heartbeat > old_time
  end

  test "has_capability? should return true for existing capability" do
    assert @agent.has_capability?("data_analysis")
  end

  test "has_capability? should return false for non-existing capability" do
    assert_not @agent.has_capability?("non_existent")
  end

  test "update_health_score should keep score between 0 and 100" do
    @agent.update_health_score(-200)
    assert_equal 0, @agent.health_score

    @agent.update_health_score(200)
    assert_equal 100, @agent.health_score
  end

  test "scopes should work correctly" do
    Agent.create!(name: "active-agent", agent_type: "test", status: "idle")
    Agent.create!(name: "busy-agent", agent_type: "test", status: "busy")
    Agent.create!(name: "failed-agent", agent_type: "test", status: "failed")

    assert_equal 2, Agent.active.count
    assert_equal 1, Agent.busy.count
    assert_equal 1, Agent.failed.count
  end
end
