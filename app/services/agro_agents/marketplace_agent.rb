module AgroAgents
  # MarketplaceAgent - Manages supply/demand matching and market operations
  class MarketplaceAgent < BaseAgroAgent
    def execute_task(task)
      task.start!

      result = case task.task_type
               when 'coordination'
                 match_offers(task.input_data)
               when 'analysis'
                 analyze_market(task.input_data)
               when 'monitoring'
                 monitor_offers(task.input_data)
               when 'prediction'
                 predict_prices(task.input_data)
               else
                 { status: 'error', message: 'Unknown task type' }
               end

      if result[:status] == 'success'
        task.complete!(result[:data])
      else
        task.fail!(result[:message])
      end

      log_execution(task, result)
      result
    rescue => e
      task.fail!(e.message)
      { status: 'error', message: e.message }
    end

    private

    def match_offers(input)
      product_type = input['product_type']

      supply_offers = MarketOffer.active.supply.by_product(product_type)
      demand_offers = MarketOffer.active.demand.by_product(product_type)

      matches = []

      demand_offers.each do |demand|
        supply_offers.each do |supply|
          if can_match?(supply, demand)
            match = create_match(supply, demand)
            matches << match if match
          end
        end
      end

      { status: 'success', data: { matches_found: matches.count, matches: matches } }
    end

    def analyze_market(input)
      product_type = input['product_type']
      offers = MarketOffer.active.by_product(product_type)

      supply = offers.supply
      demand = offers.demand

      analysis = {
        product: product_type,
        total_supply: supply.sum(:quantity),
        total_demand: demand.sum(:quantity),
        avg_supply_price: supply.average(:price_per_unit)&.round(2),
        avg_demand_price: demand.average(:price_per_unit)&.round(2),
        market_balance: calculate_market_balance(supply, demand)
      }

      { status: 'success', data: analysis }
    end

    def monitor_offers(input)
      active_offers = agent.market_offers.active
      expiring = agent.market_offers.expiring_soon

      summary = {
        total_active: active_offers.count,
        supply_offers: active_offers.supply.count,
        demand_offers: active_offers.demand.count,
        expiring_soon: expiring.count
      }

      { status: 'success', data: summary }
    end

    def predict_prices(input)
      product_type = input['product_type']

      # Use LLM for price prediction
      prompt = <<~PROMPT
        Предскажите ценовые тренды для продукта: #{product_type}

        Проанализируйте текущую рыночную ситуацию и дайте прогноз цен
        на ближайшие 30 дней.
      PROMPT

      recent_offers = MarketOffer.by_product(product_type)
                                  .where('created_at >= ?', 30.days.ago)

      llm_response = ask_llm(prompt, { product: product_type, offers_count: recent_offers.count })

      { status: 'success', data: { prediction: llm_response || 'Недостаточно данных' } }
    end

    def can_match?(supply, demand)
      supply.quantity >= demand.quantity &&
        supply.price_per_unit <= demand.price_per_unit
    end

    def create_match(supply, demand)
      contract = SmartContract.create(
        buyer_agent: demand.agro_agent,
        seller_agent: supply.agro_agent,
        contract_type: 'purchase_agreement',
        status: 'draft',
        total_amount: demand.quantity * supply.price_per_unit,
        terms: {
          product: supply.product_type,
          quantity: demand.quantity,
          price: supply.price_per_unit,
          supply_offer_id: supply.id,
          demand_offer_id: demand.id
        }
      )

      supply.update(status: 'matched')
      demand.update(status: 'matched')

      {
        contract_id: contract.id,
        buyer: demand.agro_agent.name,
        seller: supply.agro_agent.name,
        product: supply.product_type,
        quantity: demand.quantity,
        price: supply.price_per_unit
      }
    end

    def calculate_market_balance(supply, demand)
      supply_total = supply.sum(:quantity)
      demand_total = demand.sum(:quantity)

      if supply_total > demand_total
        'oversupply'
      elsif demand_total > supply_total
        'undersupply'
      else
        'balanced'
      end
    end
  end
end
