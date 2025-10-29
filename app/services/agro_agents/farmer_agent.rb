module AgroAgents
  # FarmerAgent - Manages farming operations, crops, and equipment
  class FarmerAgent < BaseAgroAgent
    def execute_task(task)
      task.start!

      result = case task.task_type
               when 'data_collection'
                 collect_farm_data(task.input_data)
               when 'analysis'
                 analyze_crop_performance(task.input_data)
               when 'optimization'
                 optimize_planting_schedule(task.input_data)
               when 'monitoring'
                 monitor_crops(task.input_data)
               when 'prediction'
                 predict_harvest(task.input_data)
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

    def collect_farm_data(input)
      farm_id = input['farm_id']
      farm = agent.farms.find_by(id: farm_id)

      return { status: 'error', message: 'Farm not found' } unless farm

      data = {
        farm: {
          name: farm.name,
          type: farm.farm_type,
          area: farm.area,
          crops_count: farm.crops.count,
          equipment_count: farm.equipment.count
        },
        crops: farm.crops.active.map { |c| crop_summary(c) },
        equipment: farm.equipment.map { |e| equipment_summary(e) }
      }

      { status: 'success', data: data }
    end

    def analyze_crop_performance(input)
      farm_id = input['farm_id']
      farm = agent.farms.find_by(id: farm_id)

      return { status: 'error', message: 'Farm not found' } unless farm

      crops = farm.crops.where.not(actual_yield: nil)

      if crops.empty?
        return { status: 'success', data: { message: 'No harvested crops to analyze' } }
      end

      analysis = {
        total_crops: crops.count,
        average_efficiency: crops.average(:area_planted),
        best_performer: crops.order(actual_yield: :desc).first&.crop_type,
        recommendations: generate_crop_recommendations(crops)
      }

      { status: 'success', data: analysis }
    end

    def optimize_planting_schedule(input)
      # Use LLM for intelligent optimization
      prompt = "Оптимизируйте график посадки культур на основе данных: #{input.to_json}"

      llm_response = ask_llm(prompt, input)

      if llm_response
        { status: 'success', data: { optimization: llm_response, source: 'llm' } }
      else
        # Fallback to rule-based optimization
        { status: 'success', data: basic_planting_optimization(input) }
      end
    end

    def monitor_crops(input)
      farm_id = input['farm_id']
      farm = agent.farms.find_by(id: farm_id)

      return { status: 'error', message: 'Farm not found' } unless farm

      active_crops = farm.active_crops
      alerts = []

      active_crops.each do |crop|
        if crop.days_to_harvest && crop.days_to_harvest < 7
          alerts << "Crop #{crop.crop_type} ready for harvest in #{crop.days_to_harvest} days"
        end
      end

      { status: 'success', data: { crops_monitored: active_crops.count, alerts: alerts } }
    end

    def predict_harvest(input)
      crop_id = input['crop_id']
      crop = Crop.find_by(id: crop_id)

      return { status: 'error', message: 'Crop not found' } unless crop

      # Use LLM for prediction
      prompt = <<~PROMPT
        Предскажите урожайность на основе данных:
        - Тип культуры: #{crop.crop_type}
        - Площадь: #{crop.area_planted} га
        - Ожидаемая урожайность: #{crop.expected_yield} тонн
        - Дата посадки: #{crop.planting_date}
        - Текущий статус: #{crop.status}
      PROMPT

      llm_response = ask_llm(prompt, crop.attributes)

      { status: 'success', data: { prediction: llm_response || 'Недостаточно данных' } }
    end

    def crop_summary(crop)
      {
        id: crop.id,
        type: crop.crop_type,
        area: crop.area_planted,
        status: crop.status,
        days_to_harvest: crop.days_to_harvest
      }
    end

    def equipment_summary(equipment)
      {
        id: equipment.id,
        name: equipment.name,
        type: equipment.equipment_type,
        status: equipment.status,
        autonomous: equipment.autonomous
      }
    end

    def generate_crop_recommendations(crops)
      [
        "Проанализировано #{crops.count} культур",
        "Средняя эффективность посевов в норме",
        "Рекомендуется плановое техническое обслуживание оборудования"
      ]
    end

    def basic_planting_optimization(input)
      {
        schedule: "Базовый график посадки",
        recommendations: ["Соблюдать севооборот", "Учитывать климатические условия"]
      }
    end
  end
end
