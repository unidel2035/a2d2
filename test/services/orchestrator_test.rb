require "test_helper"

class OrchestratorTest < ActiveSupport::TestCase
  def setup
    @orchestrator = Orchestrator.instance
  end

  test "register_agent should create new agent" do
    agent = @orchestrator.register_agent(
      name: "test-agent-1",
      agent_type: "analyzer",
      capabilities: ["analysis"],
      endpoint: "http://localhost:3000"
    )

    assert agent.persisted?
    assert_equal "test-agent-1", agent.name
    assert_equal "analyzer", agent.agent_type
    assert_includes agent.capabilities, "analysis"
  end

  test "activate_agent should activate an agent" do
    agent = Agent.create!(name: "test-agent", agent_type: "test", status: "inactive")

    @orchestrator.activate_agent(agent.id)

    agent.reload
    assert_equal "idle", agent.status
  end

  test "deactivate_agent should deactivate an agent" do
    agent = Agent.create!(name: "test-agent", agent_type: "test", status: "idle")

    @orchestrator.deactivate_agent(agent.id)

    agent.reload
    assert_equal "inactive", agent.status
  end

  test "set_distribution_strategy should update strategy" do
    @orchestrator.set_distribution_strategy(:least_loaded)
    assert_equal :least_loaded, @orchestrator.distribution_strategy
  end

  test "monitor_agents should return stats" do
    Agent.create!(name: "agent1", agent_type: "test", status: "idle")
    Agent.create!(name: "agent2", agent_type: "test", status: "busy")
    Agent.create!(name: "agent3", agent_type: "test", status: "failed")

    stats = @orchestrator.monitor_agents

    assert_equal 3, stats[:total]
    assert_equal 2, stats[:active]
    assert_equal 1, stats[:idle]
    assert_equal 1, stats[:busy]
    assert_equal 1, stats[:failed]
  end

  test "get_performance_metrics should return metrics" do
    AgentTask.create!(task_type: "test1", status: "completed")
    AgentTask.create!(task_type: "test2", status: "completed")
    AgentTask.create!(task_type: "test3", status: "failed")

    metrics = @orchestrator.get_performance_metrics

    assert_equal 3, metrics[:total_tasks]
    assert_equal 2, metrics[:completed_tasks]
    assert_equal 1, metrics[:failed_tasks]
    assert metrics[:success_rate] > 0
  end
end
