# frozen_string_literal: true

require "test_helper"

module Orchestration
  class OrchestratorTest < ActiveSupport::TestCase
    setup do
      @agent = Agent.create!(
        name: "Test Analyzer",
        type: "Agents::AnalyzerAgent",
        status: "idle",
        capabilities: { statistical_analysis: true },
        last_heartbeat_at: Time.current
      )

      @task = AgentTask.create!(
        task_type: "statistical_analysis",
        input_data: { data: [1, 2, 3, 4, 5] },
        status: "pending",
        priority: 5
      )
    end

    test "should start orchestrator" do
      result = Orchestrator.start

      assert_equal "started", result[:status]
      assert result[:timestamp].present?
      assert result[:agents].present?
      assert result[:tasks].present?
    end

    test "should process queue" do
      result = Orchestrator.process_queue(batch_size: 1)

      assert result[:processed_count] >= 0
      assert result[:results].is_a?(Array)
    end

    test "should execute task" do
      result = Orchestrator.execute_task(@task, @agent)

      assert result[:success]
      assert_equal @task.id, result[:task_id]
      assert_equal @agent.id, result[:agent_id]
    end

    test "should perform health check" do
      result = Orchestrator.health_check

      assert result[:status].present?
      assert result[:timestamp].present?
      assert result[:agents].present?
      assert result[:queue].present?
    end

    test "should optimize system" do
      result = Orchestrator.optimize

      assert result[:optimizations].is_a?(Array)
      assert result[:timestamp].present?
    end

    test "should scale agents" do
      result = Orchestrator.scale_agents(
        agent_type: "Agents::AnalyzerAgent",
        target_count: 3
      )

      assert_equal 3, result[:target_count]
      assert result[:current_count] >= 0
    end

    test "should generate statistics" do
      result = Orchestrator.statistics

      assert result[:timestamp].present?
      assert result[:agents].present?
      assert result[:tasks].present?
      assert result[:collaborations].present?
    end
  end
end
