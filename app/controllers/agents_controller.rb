class AgentsController < ApplicationController
  def index
    @agents = Agent.all.order(created_at: :desc)
    @stats = {
      total: @agents.count,
      active: @agents.active.count,
      idle: @agents.idle.count,
      busy: @agents.busy.count,
      failed: @agents.failed.count
    }

    @recent_tasks = AgentTask.order(created_at: :desc).limit(10)
  end

  def show
    @agent = Agent.find(params[:id])
    @tasks = @agent.agent_tasks.order(created_at: :desc).limit(20)
    @registry_entry = @agent.agent_registry_entry
  end
end
