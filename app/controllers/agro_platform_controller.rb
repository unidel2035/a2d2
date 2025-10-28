# Main controller for the Agricultural Platform "Kod Urozhaya" (Harvest Code)
class AgroPlatformController < ApplicationController
  def index
    @orchestrator = AgroOrchestrator.new
    @ecosystem_status = @orchestrator.monitor_ecosystem

    @total_agents = AgroAgent.count
    @active_coordinations = AgentCoordination.active.count
    @pending_tasks = AgroTask.pending.count
    @active_contracts = SmartContract.active.count

    # Recent activity
    @recent_tasks = AgroTask.order(created_at: :desc).limit(10)
    @recent_contracts = SmartContract.order(created_at: :desc).limit(5)
  end

  def ecosystem
    @agents_by_type = AgroAgent.group(:agent_type).count
    @agents_by_level = AgroAgent.group(:level).count
    @agents = AgroAgent.includes(:user).order(created_at: :desc)

    @orchestrator = AgroOrchestrator.new
    @health_status = @orchestrator.health_check
  end

  def monitoring
    @orchestrator = AgroOrchestrator.new
    @ecosystem_status = @orchestrator.monitor_ecosystem

    @pending_tasks = AgroTask.pending.includes(:agro_agent).order(priority: :desc, created_at: :asc)
    @in_progress_tasks = AgroTask.in_progress.includes(:agro_agent).order(started_at: :desc)
    @recent_completed = AgroTask.completed.includes(:agro_agent).order(completed_at: :desc).limit(20)

    @active_coordinations = AgentCoordination.active.includes(:agents).order(started_at: :desc)
  end
end
