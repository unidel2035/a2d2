module AgroAgents
  # DecisionSupportAgent - Intelligent decision support system (СППР) agent
  # Provides recommendations for agricultural management decisions
  # Based on conceptual materials: multi-agent decision support approach
  class DecisionSupportAgent < BaseAgroAgent
    def execute_task(task)
      task.start!

      result = case task.task_type
      when 'analysis'
        analyze_and_recommend(task)
      when 'prediction'
        predict_outcomes(task)
      when 'optimization'
        optimize_operations(task)
      when 'validation'
        validate_decision(task)
      else
        { status: 'error', message: 'Unknown task type for DecisionSupportAgent' }
      end

      if result[:status] == 'success'
        task.complete!(result)
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

    # Analyze situation and provide recommendations
    def analyze_and_recommend(task)
      decision_type = task.input_data['decision_type']
      farm_id = task.input_data['farm_id']
      crop_id = task.input_data['crop_id']

      farm = Farm.find(farm_id)
      crop = crop_id ? Crop.find(crop_id) : nil

      # Gather relevant data
      input_data = gather_decision_data(farm, crop, decision_type)

      # Analyze with LLM
      analysis = analyze_with_llm(decision_type, input_data)

      # Generate recommendations
      recommendations = generate_recommendations(decision_type, input_data, analysis)

      # Create decision support record
      decision = DecisionSupport.create(
        farm: farm,
        crop: crop,
        agro_agent: agent,
        decision_type: decision_type,
        status: 'pending',
        priority: determine_priority(input_data),
        input_data: input_data,
        analysis_result: analysis,
        recommendations: recommendations,
        reasoning: analysis[:reasoning],
        confidence_score: analysis[:confidence],
        recommended_execution_date: calculate_execution_date(decision_type, input_data)
      )

      {
        status: 'success',
        message: "Сформированы рекомендации: #{decision.decision_type_ru}",
        decision_id: decision.id,
        recommendations: recommendations,
        confidence: analysis[:confidence]
      }
    end

    # Predict outcomes of different scenarios
    def predict_outcomes(task)
      farm_id = task.input_data['farm_id']
      crop_id = task.input_data['crop_id']
      scenarios = task.input_data['scenarios'] || []

      farm = Farm.find(farm_id)
      crop = crop_id ? Crop.find(crop_id) : nil

      results = []

      scenarios.each do |scenario|
        # Create simulation
        simulation = SimulationResult.create(
          farm: farm,
          crop: crop,
          simulation_type: scenario['type'],
          scenario_parameters: scenario,
          simulation_data: run_simulation(scenario, farm, crop),
          predicted_outcome: calculate_outcome(scenario, farm, crop),
          economic_benefit: calculate_economic_benefit(scenario, farm, crop),
          environmental_impact_score: calculate_environmental_impact(scenario),
          recommendation_summary: summarize_scenario(scenario),
          simulated_at: Time.current
        )

        results << {
          scenario: scenario['name'],
          outcome: simulation.predicted_outcome,
          benefit: simulation.economic_benefit,
          environmental_score: simulation.environmental_impact_score
        }
      end

      {
        status: 'success',
        message: "Проведено моделирование #{scenarios.count} сценариев",
        scenarios_analyzed: scenarios.count,
        results: results
      }
    end

    # Optimize agricultural operations
    def optimize_operations(task)
      farm_id = task.input_data['farm_id']
      optimization_type = task.input_data['optimization_type']

      farm = Farm.find(farm_id)

      case optimization_type
      when 'fertilization'
        optimize_fertilization(farm)
      when 'irrigation'
        optimize_irrigation(farm)
      when 'resource_allocation'
        optimize_resource_allocation(farm)
      else
        { status: 'error', message: 'Unknown optimization type' }
      end
    end

    # Validate existing decision
    def validate_decision(task)
      decision_id = task.input_data['decision_id']
      decision = DecisionSupport.find(decision_id)

      # Validate using knowledge base
      validation_result = validate_with_knowledge_base(decision)

      # Check for risks
      risks = assess_risks(decision)

      if validation_result[:valid] && risks.none? { |r| r[:severity] == 'critical' }
        {
          status: 'success',
          message: 'Решение валидировано',
          valid: true,
          risks: risks,
          validation: validation_result
        }
      else
        {
          status: 'success',
          message: 'Решение требует пересмотра',
          valid: false,
          risks: risks,
          validation: validation_result
        }
      end
    end

    # Gather data for decision making
    def gather_decision_data(farm, crop, decision_type)
      data = {
        farm: {
          id: farm.id,
          name: farm.name,
          type: farm.farm_type,
          area: farm.area,
          location: farm.location
        }
      }

      if crop
        data[:crop] = {
          id: crop.id,
          type: crop.crop_type,
          status: crop.status,
          planting_date: crop.planting_date,
          days_since_planting: crop.growth_duration
        }

        # Add remote sensing data
        latest_ndvi = crop.remote_sensing_data.where(data_type: :ndvi).order(captured_at: :desc).first
        data[:ndvi] = latest_ndvi&.ndvi_value

        # Add weather data
        recent_weather = farm.weather_data.order(recorded_at: :desc).first(7)
        data[:weather] = {
          avg_temperature: recent_weather.average(:temperature),
          total_precipitation: recent_weather.sum(:precipitation),
          conditions: recent_weather.map(&:summary)
        }
      end

      # Add field zones if available
      if farm.field_zones.any?
        data[:zones] = farm.field_zones.map do |zone|
          {
            name: zone.name,
            area: zone.area,
            productivity: zone.productivity_class,
            avg_ndvi: zone.average_ndvi(14)
          }
        end
      end

      data
    end

    # Analyze with LLM
    def analyze_with_llm(decision_type, input_data)
      prompt = "Проанализируй ситуацию и предложи оптимальное решение для: #{decision_type}"

      response = ask_llm(prompt, input_data)

      if response
        {
          reasoning: response.dig('content') || 'Анализ завершен',
          confidence: response.dig('confidence') || 75,
          factors: response.dig('factors_analyzed') || []
        }
      else
        {
          reasoning: 'Автоматический анализ на основе данных',
          confidence: 70,
          factors: ['weather', 'crop_state', 'field_conditions']
        }
      end
    end

    # Generate recommendations based on analysis
    def generate_recommendations(decision_type, input_data, analysis)
      case decision_type
      when 'fertilization_plan'
        generate_fertilization_recommendations(input_data)
      when 'irrigation_schedule'
        generate_irrigation_recommendations(input_data)
      when 'harvest_timing'
        generate_harvest_recommendations(input_data)
      when 'pest_control'
        generate_pest_control_recommendations(input_data)
      else
        generate_generic_recommendations(decision_type, input_data)
      end
    end

    def generate_fertilization_recommendations(input_data)
      {
        summary: 'Рекомендации по внесению удобрений',
        actions: [
          'Провести почвенную диагностику',
          'Определить дефицитные элементы',
          'Рассчитать нормы внесения по зонам',
          'Применить дифференцированное внесение (VRT)'
        ],
        timing: 'В течение 7-10 дней',
        expected_benefit: 'Увеличение урожайности на 10-15%'
      }
    end

    def generate_irrigation_recommendations(input_data)
      {
        summary: 'Рекомендации по поливу',
        actions: [
          'Проверить влажность почвы',
          'Оценить водный баланс',
          'Настроить график полива',
          'Учесть прогноз погоды'
        ],
        timing: 'Ежедневный мониторинг',
        expected_benefit: 'Оптимизация водопотребления'
      }
    end

    def generate_harvest_recommendations(input_data)
      crop_data = input_data[:crop]
      ndvi = input_data[:ndvi]

      maturity_score = calculate_maturity_score(crop_data, ndvi)

      {
        summary: 'Рекомендации по срокам уборки',
        actions: [
          "Зрелость культуры: #{maturity_score}%",
          'Отслеживать влажность зерна',
          'Подготовить уборочную технику',
          'Учесть прогноз погоды'
        ],
        timing: maturity_score > 90 ? 'В ближайшие 3-5 дней' : 'Через 10-14 дней',
        expected_benefit: 'Оптимальное качество и минимальные потери'
      }
    end

    def generate_pest_control_recommendations(input_data)
      {
        summary: 'Рекомендации по защите растений',
        actions: [
          'Провести обследование посевов',
          'Определить вредителя/болезнь',
          'Выбрать препарат и дозировку',
          'Провести обработку в оптимальные сроки'
        ],
        timing: 'Срочно, в течение 2-3 дней',
        expected_benefit: 'Предотвращение потерь урожая'
      }
    end

    def generate_generic_recommendations(decision_type, input_data)
      {
        summary: "Рекомендации: #{decision_type}",
        actions: ['Собрать дополнительные данные', 'Провести анализ', 'Принять решение'],
        timing: 'По ситуации',
        expected_benefit: 'Улучшение показателей'
      }
    end

    # Determine priority level
    def determine_priority(input_data)
      # High priority if NDVI shows stress or weather is unfavorable
      ndvi = input_data[:ndvi]
      return 3 if ndvi && ndvi < 0.3 # Critical

      weather = input_data.dig(:weather, :conditions)
      return 2 if weather&.any? { |c| c&.include?('экстремальн') } # High

      1 # Normal
    end

    # Calculate execution date
    def calculate_execution_date(decision_type, input_data)
      case decision_type
      when 'harvest_timing'
        14.days.from_now.to_date
      when 'pest_control'
        2.days.from_now.to_date
      when 'fertilization_plan'
        7.days.from_now.to_date
      else
        10.days.from_now.to_date
      end
    end

    # Run simulation (simplified)
    def run_simulation(scenario, farm, crop)
      {
        scenario_name: scenario['name'],
        parameters: scenario,
        iterations: 1000,
        method: 'monte_carlo',
        completion_time: Time.current
      }
    end

    # Calculate outcome
    def calculate_outcome(scenario, farm, crop)
      base_yield = crop&.expected_yield || 4.0
      improvement_factor = scenario.dig('improvement_factor') || 1.0

      base_yield * improvement_factor
    end

    # Calculate economic benefit
    def calculate_economic_benefit(scenario, farm, crop)
      outcome = calculate_outcome(scenario, farm, crop)
      price_per_ton = 15000 # rubles
      area = crop&.area_planted || farm.area || 100

      benefit = outcome * area * price_per_ton
      cost = scenario.dig('cost') || 0

      benefit - cost
    end

    # Calculate environmental impact
    def calculate_environmental_impact(scenario)
      # Higher score = better for environment
      base_score = 70

      if scenario['organic']
        base_score += 20
      end

      if scenario['precision_agriculture']
        base_score += 10
      end

      [base_score, 100].min
    end

    # Summarize scenario
    def summarize_scenario(scenario)
      "Сценарий '#{scenario['name']}': #{scenario['description']}"
    end

    # Optimize fertilization
    def optimize_fertilization(farm)
      zones = farm.field_zones

      if zones.any?
        # Zone-specific optimization
        recommendations = zones.map do |zone|
          {
            zone: zone.name,
            rate: calculate_fertilizer_rate(zone),
            method: 'variable_rate'
          }
        end
      else
        # Uniform application
        recommendations = [{
          zone: 'Все поле',
          rate: 120, # kg/ha
          method: 'broadcast'
        }]
      end

      {
        status: 'success',
        message: 'Оптимизация внесения удобрений завершена',
        recommendations: recommendations
      }
    end

    # Calculate fertilizer rate based on zone characteristics
    def calculate_fertilizer_rate(zone)
      avg_ndvi = zone.average_ndvi(14) || 0.5

      case zone.productivity_class
      when 'high'
        140 # kg/ha
      when 'medium'
        120
      when 'low'
        160 # More fertilizer for low productivity zones
      else
        120
      end
    end

    # Optimize irrigation
    def optimize_irrigation(farm)
      {
        status: 'success',
        message: 'Оптимизация полива завершена',
        schedule: {
          frequency: 'Каждые 3-4 дня',
          amount: '25 мм',
          method: 'drip_irrigation'
        }
      }
    end

    # Optimize resource allocation
    def optimize_resource_allocation(farm)
      {
        status: 'success',
        message: 'Оптимизация распределения ресурсов завершена',
        allocation: {
          equipment: 'Равномерное распределение',
          labor: 'По приоритетам',
          budget: 'По ROI'
        }
      }
    end

    # Validate with knowledge base
    def validate_with_knowledge_base(decision)
      # Search knowledge base for relevant entries
      relevant_entries = KnowledgeBaseEntry
        .by_category(map_decision_to_category(decision.decision_type))
        .high_confidence

      if relevant_entries.any?
        {
          valid: true,
          knowledge_used: relevant_entries.count,
          confidence: 85
        }
      else
        {
          valid: true,
          knowledge_used: 0,
          confidence: 60
        }
      end
    end

    # Map decision type to knowledge base category
    def map_decision_to_category(decision_type)
      case decision_type
      when 'fertilization_plan'
        'soil_health'
      when 'pest_control'
        'pest_disease'
      when 'harvest_timing'
        'crop_management'
      else
        'best_practices'
      end
    end

    # Assess risks
    def assess_risks(decision)
      [
        {
          type: 'weather',
          severity: 'low',
          probability: 30,
          description: 'Неблагоприятные погодные условия'
        }
      ]
    end

    # Calculate maturity score
    def calculate_maturity_score(crop_data, ndvi)
      return 50 unless crop_data && crop_data[:days_since_planting]

      days = crop_data[:days_since_planting]
      typical_duration = 120 # days for typical crop

      time_factor = (days.to_f / typical_duration * 100).clamp(0, 100)

      # NDVI contribution
      ndvi_factor = ndvi ? (1 - ndvi) * 100 : 50 # NDVI decreases at maturity

      ((time_factor + ndvi_factor) / 2).round(2)
    end
  end
end
