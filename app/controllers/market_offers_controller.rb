# Controller for managing market offers (supply/demand)
class MarketOffersController < ApplicationController
  before_action :set_offer, only: [:show, :edit, :update, :destroy]

  def index
    @offers = MarketOffer.includes(:agro_agent).order(created_at: :desc)
    @offers = @offers.where(offer_type: params[:offer_type]) if params[:offer_type].present?
    @offers = @offers.by_product(params[:product_type]) if params[:product_type].present?
    @offers = @offers.where(status: params[:status]) if params[:status].present?

    @supply_offers = @offers.supply
    @demand_offers = @offers.demand
  end

  def show
  end

  def new
    @offer = MarketOffer.new
    @agents = AgroAgent.active
  end

  def create
    @offer = MarketOffer.new(offer_params)

    if @offer.save
      redirect_to @offer, notice: 'Предложение успешно создано'
    else
      @agents = AgroAgent.active
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @agents = AgroAgent.active
  end

  def update
    if @offer.update(offer_params)
      redirect_to @offer, notice: 'Предложение успешно обновлено'
    else
      @agents = AgroAgent.active
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @offer.destroy
    redirect_to market_offers_url, notice: 'Предложение успешно удалено'
  end

  def match
    orchestrator = AgroOrchestrator.new
    product_type = params[:product_type]

    result = orchestrator.assign_task(
      'coordination',
      { product_type: product_type, action: 'match_offers' },
      priority: 'high'
    )

    if result[:success]
      redirect_to market_offers_url, notice: 'Запущен процесс сведения предложений'
    else
      redirect_to market_offers_url, alert: 'Ошибка при запуске процесса'
    end
  end

  private

  def set_offer
    @offer = MarketOffer.find(params[:id])
  end

  def offer_params
    params.require(:market_offer).permit(
      :agro_agent_id, :offer_type, :product_type, :quantity,
      :unit, :price_per_unit, :status, :valid_until, conditions: {}
    )
  end
end
