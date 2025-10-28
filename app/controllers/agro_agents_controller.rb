# Controller for managing agricultural agents
class AgroAgentsController < ApplicationController
  before_action :set_agent, only: [:show, :edit, :update, :destroy, :heartbeat]

  def index
    @agents = AgroAgent.includes(:user).order(created_at: :desc)
    @agents = @agents.by_type(params[:type]) if params[:type].present?
    @agents = @agents.by_level(params[:level]) if params[:level].present?
  end

  def show
    @tasks = @agent.agro_tasks.order(created_at: :desc).limit(50)
    @farms = @agent.farms if @agent.agent_type == 'farmer'
    @orders = @agent.logistics_orders.order(created_at: :desc).limit(20) if @agent.agent_type == 'logistics'
    @batches = @agent.processing_batches.order(created_at: :desc).limit(20) if @agent.agent_type == 'processor'
    @offers = @agent.market_offers.order(created_at: :desc).limit(20) if @agent.agent_type == 'marketplace'
  end

  def new
    @agent = AgroAgent.new
  end

  def create
    @agent = AgroAgent.new(agent_params)
    @agent.user = current_user if respond_to?(:current_user)

    if @agent.save
      redirect_to @agent, notice: 'Агент успешно создан'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @agent.update(agent_params)
      redirect_to @agent, notice: 'Агент успешно обновлен'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @agent.destroy
    redirect_to agro_agents_url, notice: 'Агент успешно удален'
  end

  def heartbeat
    @agent.heartbeat!
    render json: { status: 'ok', timestamp: @agent.last_heartbeat }
  end

  private

  def set_agent
    @agent = AgroAgent.find(params[:id])
  end

  def agent_params
    params.require(:agro_agent).permit(
      :name, :agent_type, :level, :status,
      capabilities: [], configuration: {}
    )
  end
end
