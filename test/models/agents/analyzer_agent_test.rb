require "test_helper"

module Agents
  class AnalyzerAgentTest < ActiveSupport::TestCase
    def setup
      @agent = AnalyzerAgent.new(name: "Test Analyzer")
      @numeric_data = [ 1, 2, 3, 4, 5, 10, 15, 20 ]
    end

    test "initializes with correct capabilities" do
      assert @agent.capabilities[:statistical_analysis]
      assert @agent.capabilities[:anomaly_detection]
      assert @agent.capabilities[:data_profiling]
    end

    test "performs statistical analysis" do
      task = AgentTask.new(
        task_type: "analyze",
        input_data: { "data" => @numeric_data, "analysis_type" => "statistical" }
      )

      result = @agent.execute(task)
      assert result[:count] == 8
      assert result[:mean] == 7.5
      assert result[:min] == 1
      assert result[:max] == 20
    end

    test "detects anomalies" do
      task = AgentTask.new(
        task_type: "analyze",
        input_data: { "data" => @numeric_data, "analysis_type" => "anomaly" }
      )

      result = @agent.execute(task)
      assert result.key?(:anomalies)
      assert result.key?(:count)
    end

    test "profiles data" do
      task = AgentTask.new(
        task_type: "analyze",
        input_data: { "data" => @numeric_data, "analysis_type" => "profile" }
      )

      result = @agent.execute(task)
      assert_equal 8, result[:total_records]
      assert result.key?(:data_types)
      assert_equal 8, result[:unique_count]
    end

    test "analyzes trends" do
      task = AgentTask.new(
        task_type: "analyze",
        input_data: { "data" => @numeric_data, "analysis_type" => "trend" }
      )

      result = @agent.execute(task)
      assert result.key?(:trend)
      assert result.key?(:slope)
      assert_equal "increasing", result[:trend]
    end
  end
end
