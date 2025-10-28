# Controller for managing farms
class FarmsController < ApplicationController
  before_action :set_farm, only: [:show, :edit, :update, :destroy]

  def index
    @farms = Farm.includes(:agro_agent, :user).order(created_at: :desc)
    @farms = @farms.by_type(params[:farm_type]) if params[:farm_type].present?
  end

  def show
    @crops = @farm.crops.order(created_at: :desc)
    @equipment = @farm.equipment.order(created_at: :desc)
  end

  def new
    @farm = Farm.new
    @agents = AgroAgent.where(agent_type: 'farmer')
  end

  def create
    @farm = Farm.new(farm_params)
    @farm.user = current_user if respond_to?(:current_user)

    if @farm.save
      redirect_to @farm, notice: 'Ферма успешно создана'
    else
      @agents = AgroAgent.where(agent_type: 'farmer')
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @agents = AgroAgent.where(agent_type: 'farmer')
  end

  def update
    if @farm.update(farm_params)
      redirect_to @farm, notice: 'Ферма успешно обновлена'
    else
      @agents = AgroAgent.where(agent_type: 'farmer')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @farm.destroy
    redirect_to farms_url, notice: 'Ферма успешно удалена'
  end

  private

  def set_farm
    @farm = Farm.find(params[:id])
  end

  def farm_params
    params.require(:farm).permit(:name, :farm_type, :location, :area, :agro_agent_id, coordinates: {})
  end
end
