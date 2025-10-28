# SimulationResult - Results from AGROTOOL-like simulation system
# Scenario modeling and optimization for agricultural operations
# Based on conceptual materials: simulation approach for decision support
class SimulationResult < ApplicationRecord
  belongs_to :farm
  belongs_to :crop, optional: true
  belongs_to :adaptive_agrotechnology, optional: true

  SIMULATION_TYPES = %w[
    yield_optimization
    cost_minimization
    risk_assessment
    resource_optimization
    scenario_comparison
    climate_adaptation
  ].freeze

  validates :simulation_type, presence: true, inclusion: { in: SIMULATION_TYPES }

  serialize :scenario_parameters, coder: JSON
  serialize :simulation_data, coder: JSON

  scope :recent, -> { where('simulated_at >= ?', 90.days.ago) }
  scope :by_type, ->(type) { where(simulation_type: type) }
  scope :for_farm, ->(farm_id) { where(farm_id: farm_id) }
  scope :for_crop, ->(crop_id) { where(crop_id: crop_id) }
  scope :profitable, -> { where('economic_benefit > 0') }

  # Get simulation type in Russian
  def simulation_type_ru
    case simulation_type
    when 'yield_optimization'
      'Оптимизация урожайности'
    when 'cost_minimization'
      'Минимизация затрат'
    when 'risk_assessment'
      'Оценка рисков'
    when 'resource_optimization'
      'Оптимизация ресурсов'
    when 'scenario_comparison'
      'Сравнение сценариев'
    when 'climate_adaptation'
      'Адаптация к климату'
    else
      simulation_type.humanize
    end
  end

  # Get environmental impact classification
  def environmental_impact_classification
    return 'Не определено' unless environmental_impact_score.present?

    case environmental_impact_score
    when 80..100
      'Очень благоприятное'
    when 60..79
      'Благоприятное'
    when 40..59
      'Нейтральное'
    when 20..39
      'Умеренно негативное'
    else
      'Негативное'
    end
  end

  # Get economic benefit with currency
  def economic_benefit_formatted
    return 'Не определено' unless economic_benefit.present?

    if economic_benefit >= 0
      "+#{economic_benefit.round(2)} руб."
    else
      "#{economic_benefit.round(2)} руб."
    end
  end

  # Get predicted outcome with interpretation
  def predicted_outcome_formatted
    return 'Не определено' unless predicted_outcome.present?

    case simulation_type
    when 'yield_optimization'
      "#{predicted_outcome.round(2)} т/га"
    when 'cost_minimization'
      "#{predicted_outcome.round(2)} руб/га"
    when 'risk_assessment'
      "#{predicted_outcome.round(2)}% риск"
    else
      predicted_outcome.round(2).to_s
    end
  end

  # Get scenario parameters summary
  def scenario_summary
    return 'Нет параметров' unless scenario_parameters.present? && scenario_parameters.is_a?(Hash)

    parts = []
    parts << "Вариантов: #{scenario_parameters['scenarios_count']}" if scenario_parameters['scenarios_count']
    parts << "Период: #{scenario_parameters['time_period']}" if scenario_parameters['time_period']
    parts << "Культура: #{scenario_parameters['crop_type']}" if scenario_parameters['crop_type']

    parts.any? ? parts.join(' | ') : 'Параметры доступны'
  end

  # Compare with another simulation
  def compare_with(other_simulation)
    return nil unless other_simulation.is_a?(SimulationResult)

    {
      outcome_difference: predicted_outcome.to_f - other_simulation.predicted_outcome.to_f,
      economic_difference: economic_benefit.to_f - other_simulation.economic_benefit.to_f,
      environmental_difference: environmental_impact_score.to_f - other_simulation.environmental_impact_score.to_f
    }
  end

  # Check if simulation is profitable
  def profitable?
    economic_benefit.present? && economic_benefit > 0
  end

  # Check if simulation is environmentally friendly
  def environmentally_friendly?
    environmental_impact_score.present? && environmental_impact_score >= 60
  end

  # Get recommendation confidence
  def recommendation_confidence
    return 'Низкая' unless simulation_data.present? && simulation_data.is_a?(Hash)

    confidence = simulation_data.dig('confidence')
    return 'Не определена' unless confidence

    case confidence
    when 0..40
      'Низкая'
    when 41..70
      'Средняя'
    else
      'Высокая'
    end
  end

  # Get full summary for display
  def full_summary
    [
      simulation_type_ru,
      predicted_outcome_formatted,
      economic_benefit_formatted,
      environmental_impact_classification,
      recommendation_summary
    ].compact.join(' | ')
  end

  # Check if simulation is recent and relevant
  def is_current?
    simulated_at.present? && simulated_at >= 60.days.ago
  end
end
