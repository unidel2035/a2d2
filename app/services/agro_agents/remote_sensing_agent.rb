module AgroAgents
  # RemoteSensingAgent - Agent for processing remote sensing data (ДЗЗ)
  # Integrates satellite, UAV, and ground sensor data for precision agriculture
  # Based on conceptual materials: Borgest N.M. - ontology of precision agriculture
  class RemoteSensingAgent < BaseAgroAgent
    def execute_task(task)
      task.start!

      result = case task.task_type
      when 'data_collection'
        collect_remote_sensing_data(task)
      when 'analysis'
        analyze_field_variability(task)
      when 'monitoring'
        monitor_crop_health(task)
      when 'prediction'
        predict_yield_zones(task)
      else
        { status: 'error', message: 'Unknown task type for RemoteSensingAgent' }
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

    # Collect remote sensing data from various sources
    def collect_remote_sensing_data(task)
      farm_id = task.input_data['farm_id']
      source_type = task.input_data['source_type'] || 'satellite'

      farm = Farm.find(farm_id)

      # In production, this would integrate with actual APIs:
      # - VEGA-Pro from IKI RAS for satellite data
      # - UAV control systems
      # - IoT sensor networks

      data_points = simulate_data_collection(farm, source_type)

      saved_count = 0
      data_points.each do |data_point|
        remote_sensing = RemoteSensingData.create(
          farm: farm,
          crop: data_point[:crop],
          field_zone: data_point[:field_zone],
          source_type: source_type,
          data_type: data_point[:data_type],
          source_name: data_point[:source_name],
          captured_at: Time.current,
          data: data_point[:data],
          metadata: data_point[:metadata],
          ndvi_value: data_point[:ndvi_value],
          confidence_score: data_point[:confidence_score]
        )
        saved_count += 1 if remote_sensing.persisted?
      end

      {
        status: 'success',
        message: "Собрано #{saved_count} точек данных ДЗЗ для хозяйства #{farm.name}",
        data_points: saved_count,
        source: source_type
      }
    end

    # Analyze field variability using NDVI and other indices
    def analyze_field_variability(task)
      crop_id = task.input_data['crop_id']
      crop = Crop.find(crop_id)
      farm = crop.farm

      # Get recent NDVI data
      ndvi_data = RemoteSensingData
        .where(crop: crop, data_type: :ndvi)
        .where('captured_at >= ?', 14.days.ago)
        .order(captured_at: :desc)

      return { status: 'error', message: 'Недостаточно данных для анализа' } if ndvi_data.count < 5

      # Analyze variability and create/update field zones
      zones = identify_productivity_zones(farm, ndvi_data)

      zones_created = 0
      zones.each do |zone_data|
        zone = FieldZone.find_or_initialize_by(
          farm: farm,
          name: zone_data[:name]
        )
        zone.update(
          geometry: zone_data[:geometry],
          area: zone_data[:area],
          productivity_class: zone_data[:productivity_class],
          characteristics: zone_data[:characteristics]
        )
        zones_created += 1 if zone.persisted?
      end

      # Use LLM for intelligent analysis
      llm_analysis = analyze_with_llm(crop, ndvi_data, zones)

      {
        status: 'success',
        message: "Проанализирована вариабельность поля для #{crop.crop_type}",
        zones_created: zones_created,
        average_ndvi: ndvi_data.average(:ndvi_value)&.round(3),
        analysis: llm_analysis
      }
    end

    # Monitor crop health using remote sensing
    def monitor_crop_health(task)
      farm_id = task.input_data['farm_id']
      farm = Farm.find(farm_id)

      crops = farm.crops.active
      health_reports = []

      crops.each do |crop|
        latest_ndvi = crop.remote_sensing_data
          .where(data_type: :ndvi)
          .order(captured_at: :desc)
          .first

        next unless latest_ndvi

        health_status = assess_crop_health(crop, latest_ndvi)
        health_reports << health_status

        # Create decision support if intervention needed
        if health_status[:needs_attention]
          create_health_intervention_decision(crop, health_status)
        end
      end

      {
        status: 'success',
        message: "Мониторинг здоровья посевов завершен",
        crops_monitored: crops.count,
        issues_found: health_reports.count { |r| r[:needs_attention] },
        health_reports: health_reports
      }
    end

    # Predict yield for different zones
    def predict_yield_zones(task)
      crop_id = task.input_data['crop_id']
      crop = Crop.find(crop_id)
      farm = crop.farm

      field_zones = farm.field_zones
      predictions = []

      field_zones.each do |zone|
        # Get NDVI trend for zone
        ndvi_trend = zone.remote_sensing_data
          .where(data_type: :ndvi)
          .where('captured_at >= ?', 30.days.ago)
          .order(:captured_at)
          .pluck(:captured_at, :ndvi_value)

        next if ndvi_trend.empty?

        # Simple yield prediction based on NDVI
        avg_ndvi = zone.average_ndvi(30)
        predicted_yield = estimate_yield_from_ndvi(crop.crop_type, avg_ndvi)

        predictions << {
          zone_id: zone.id,
          zone_name: zone.name,
          avg_ndvi: avg_ndvi,
          predicted_yield: predicted_yield,
          confidence: calculate_confidence(ndvi_trend)
        }

        # Create plant production model record
        PlantProductionModel.create(
          crop: crop,
          field_zone: zone,
          model_type: 'regression',
          model_version: '1.0',
          plant_state: { avg_ndvi: avg_ndvi },
          predicted_yield: predicted_yield,
          confidence_level: calculate_confidence(ndvi_trend),
          prediction_date: Time.current
        )
      end

      {
        status: 'success',
        message: "Прогноз урожайности по зонам завершен",
        zones_analyzed: field_zones.count,
        predictions: predictions
      }
    end

    # Simulate data collection (in production, integrate with real APIs)
    def simulate_data_collection(farm, source_type)
      crops = farm.crops.active
      zones = farm.field_zones

      data_points = []

      crops.first(3).each do |crop|
        if zones.any?
          zones.first(5).each do |zone|
            data_points << generate_data_point(crop, zone, source_type)
          end
        else
          data_points << generate_data_point(crop, nil, source_type)
        end
      end

      data_points
    end

    def generate_data_point(crop, zone, source_type)
      {
        crop: crop,
        field_zone: zone,
        data_type: :ndvi,
        source_name: get_source_name(source_type),
        data: {
          bands: { red: rand(0.1..0.3), nir: rand(0.4..0.8) },
          resolution: source_type == 'satellite' ? 10 : 0.1
        },
        metadata: {
          cloud_cover: rand(0..20),
          sun_angle: rand(30..60)
        },
        ndvi_value: rand(0.3..0.85),
        confidence_score: rand(75..95)
      }
    end

    def get_source_name(source_type)
      case source_type
      when 'satellite'
        ['VEGA-Pro (IKI RAS)', 'Resurs-P', 'Sentinel-2'].sample
      when 'drone'
        ['Geokan 201 Agro', 'DJI Agras', 'Геоскан Агро'].sample
      else
        'Наземные датчики'
      end
    end

    # Identify productivity zones based on NDVI clustering
    def identify_productivity_zones(farm, ndvi_data)
      avg_ndvi = ndvi_data.average(:ndvi_value)

      # Simple zone classification (in production, use clustering algorithms)
      [
        {
          name: 'Зона высокой продуктивности',
          geometry: { type: 'Polygon', coordinates: [] },
          area: farm.area.to_f * 0.4,
          productivity_class: 'high',
          characteristics: { avg_ndvi: avg_ndvi + 0.1, soil_fertility: 'high' }
        },
        {
          name: 'Зона средней продуктивности',
          geometry: { type: 'Polygon', coordinates: [] },
          area: farm.area.to_f * 0.4,
          productivity_class: 'medium',
          characteristics: { avg_ndvi: avg_ndvi, soil_fertility: 'medium' }
        },
        {
          name: 'Зона низкой продуктивности',
          geometry: { type: 'Polygon', coordinates: [] },
          area: farm.area.to_f * 0.2,
          productivity_class: 'low',
          characteristics: { avg_ndvi: avg_ndvi - 0.15, soil_fertility: 'low' }
        }
      ]
    end

    # Assess crop health from NDVI data
    def assess_crop_health(crop, latest_ndvi)
      ndvi = latest_ndvi.ndvi_value

      needs_attention = ndvi < 0.4
      health_score = (ndvi * 100).round(2)

      {
        crop_id: crop.id,
        crop_type: crop.crop_type,
        ndvi: ndvi,
        health_score: health_score,
        classification: latest_ndvi.ndvi_classification,
        needs_attention: needs_attention,
        interpretation: latest_ndvi.interpretation
      }
    end

    # Create decision support for health intervention
    def create_health_intervention_decision(crop, health_status)
      DecisionSupport.create(
        farm: crop.farm,
        crop: crop,
        agro_agent: agent,
        decision_type: 'pest_control',
        status: 'pending',
        priority: health_status[:health_score] < 40 ? 3 : 2,
        input_data: health_status,
        recommendations: {
          actions: [
            'Провести обследование поля',
            'Проверить на наличие вредителей и болезней',
            'Оценить водный стресс',
            'Рассмотреть внесение подкормки'
          ]
        },
        reasoning: "NDVI #{health_status[:ndvi]} указывает на стресс растений. #{health_status[:interpretation]}",
        confidence_score: 75,
        recommended_execution_date: 2.days.from_now.to_date
      )
    end

    # Analyze with LLM for intelligent insights
    def analyze_with_llm(crop, ndvi_data, zones)
      context = {
        crop_type: crop.crop_type,
        planting_date: crop.planting_date,
        avg_ndvi: ndvi_data.average(:ndvi_value)&.round(3),
        zones_count: zones.count,
        data_points: ndvi_data.count
      }

      prompt = "Проанализируй данные NDVI и дай рекомендации по управлению посевами."

      response = ask_llm(prompt, context)
      response&.dig('content') || 'Анализ недоступен'
    end

    # Estimate yield from NDVI (simplified empirical model)
    def estimate_yield_from_ndvi(crop_type, avg_ndvi)
      return nil unless avg_ndvi

      # Simplified correlation (in production, use crop-specific models)
      base_yield = case crop_type.downcase
      when /wheat|пшеница/
        4.5
      when /corn|кукуруза/
        6.0
      when /barley|ячмень/
        3.5
      else
        4.0
      end

      # NDVI correlation factor (0.6-0.9 NDVI = optimal)
      ndvi_factor = if avg_ndvi >= 0.7
        1.2
      elsif avg_ndvi >= 0.5
        1.0
      elsif avg_ndvi >= 0.3
        0.7
      else
        0.4
      end

      (base_yield * ndvi_factor).round(2)
    end

    # Calculate confidence based on data quality
    def calculate_confidence(ndvi_trend)
      return 50 if ndvi_trend.empty?

      # More data points = higher confidence
      data_quality = [ndvi_trend.count * 5, 100].min

      # Consistent trend = higher confidence
      values = ndvi_trend.map { |_date, value| value }
      std_dev = Math.sqrt(values.map { |v| (v - values.sum / values.size)**2 }.sum / values.size)
      consistency = (1 - std_dev) * 100

      ((data_quality + consistency) / 2).round(2)
    end
  end
end
