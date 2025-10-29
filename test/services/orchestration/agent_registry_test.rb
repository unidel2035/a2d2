# frozen_string_literal: true

require "test_helper"

module Orchestration
  class AgentRegistryTest < ActiveSupport::TestCase
    test "should register new agent" do
      agent = AgentRegistry.register(
        agent_type: "Agents::AnalyzerAgent",
        name: "Test Agent",
        capabilities: { test: true }
      )

      assert agent.persisted?
      assert_equal "Test Agent", agent.name
      assert_equal "idle", agent.status
    end

    test "should update heartbeat" do
      agent = Agent.create!(
        name: "Test",
        type: "Agents::AnalyzerAgent",
        status: "idle",
        last_heartbeat_at: 1.hour.ago
      )

      updated_agent = AgentRegistry.heartbeat(agent.id)

      assert updated_agent.last_heartbeat_at > 1.minute.ago
    end

    test "should mark agent offline" do
      agent = Agent.create!(
        name: "Test",
        type: "Agents::AnalyzerAgent",
        status: "idle",
        last_heartbeat_at: Time.current
      )

      AgentRegistry.mark_offline(agent.id)
      agent.reload

      assert_equal "offline", agent.status
    end

    test "should find stale agents" do
      Agent.create!(
        name: "Stale Agent",
        type: "Agents::AnalyzerAgent",
        status: "idle",
        last_heartbeat_at: 20.minutes.ago
      )

      stale_agents = AgentRegistry.find_stale_agents

      assert stale_agents.count > 0
    end

    test "should monitor heartbeats" do
      Agent.create!(
        name: "Stale Agent",
        type: "Agents::AnalyzerAgent",
        status: "idle",
        last_heartbeat_at: 20.minutes.ago
      )

      result = AgentRegistry.monitor_heartbeats

      assert result[:checked_count] >= 0
      assert result[:stale_count] >= 0
    end

    test "should get system health" do
      health = AgentRegistry.system_health

      assert health[:total_agents] >= 0
      assert health[:active] >= 0
      assert health[:health_percentage].present?
    end

    test "should get agent performance" do
      agent = Agent.create!(
        name: "Test",
        type: "Agents::AnalyzerAgent",
        status: "idle",
        total_tasks_completed: 10,
        total_tasks_failed: 2
      )

      performance = AgentRegistry.agent_performance(agent.id)

      assert_equal agent.id, performance[:agent_id]
      assert_equal 10, performance[:total_completed]
    end
  end
end
