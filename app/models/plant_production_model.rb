# PlantProductionModel - Mathematical models for crop yield prediction
# Implementation of Plant-Soil-Atmosphere (PSA) model
# Based on conceptual materials: simulation modeling approach from Yakushev's AGROTOOL
class PlantProductionModel < ApplicationRecord
  belongs_to :crop
  belongs_to :field_zone, optional: true
  belongs_to :agrotechnology_ontology, optional: true

  MODEL_TYPES = %w[psa_model regression machine_learning empirical].freeze

  validates :model_type, presence: true, inclusion: { in: MODEL_TYPES }
  validates :confidence_level, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  serialize :weather_data, coder: JSON
  serialize :soil_parameters, coder: JSON
  serialize :plant_state, coder: JSON
  serialize :management_practices, coder: JSON
  serialize :model_parameters, coder: JSON

  scope :recent, -> { where('prediction_date >= ?', 30.days.ago) }
  scope :by_model_type, ->(type) { where(model_type: type) }
  scope :high_confidence, -> { where('confidence_level >= ?', 75) }
  scope :for_crop, ->(crop_id) { where(crop_id: crop_id) }

  # Get yield prediction with units
  def predicted_yield_with_unit
    return 'Не определено' unless predicted_yield.present?

    "#{predicted_yield.round(2)} т/га"
  end

  # Get quality prediction description
  def quality_description
    return 'Не определено' unless predicted_quality.present?

    case predicted_quality
    when 90..100
      'Отличное качество'
    when 75..89
      'Хорошее качество'
    when 60..74
      'Среднее качество'
    else
      'Ниже среднего'
    end
  end

  # Calculate days until predicted harvest
  def days_until_harvest
    return nil unless harvest_date_prediction.present?

    (harvest_date_prediction - Date.current).to_i
  end

  # Get model type in Russian
  def model_type_ru
    case model_type
    when 'psa_model'
      'Модель Растение-Почва-Атмосфера'
    when 'regression'
      'Регрессионная модель'
    when 'machine_learning'
      'Машинное обучение'
    when 'empirical'
      'Эмпирическая модель'
    else
      model_type.humanize
    end
  end

  # Get confidence level description
  def confidence_description
    return 'Не определен' unless confidence_level.present?

    case confidence_level
    when 90..100
      'Очень высокая уверенность'
    when 75..89
      'Высокая уверенность'
    when 60..74
      'Средняя уверенность'
    when 40..59
      'Низкая уверенность'
    else
      'Очень низкая уверенность'
    end
  end

  # Get weather summary from model input
  def weather_summary
    return 'Нет данных' unless weather_data.present? && weather_data.is_a?(Hash)

    parts = []
    parts << "Температура: #{weather_data['avg_temperature']}°C" if weather_data['avg_temperature']
    parts << "Осадки: #{weather_data['total_precipitation']} мм" if weather_data['total_precipitation']
    parts << "ГТК: #{weather_data['hydrothermal_coefficient']}" if weather_data['hydrothermal_coefficient']

    parts.any? ? parts.join(' | ') : 'Данные доступны'
  end

  # Get soil summary from model input
  def soil_summary
    return 'Нет данных' unless soil_parameters.present? && soil_parameters.is_a?(Hash)

    parts = []
    parts << "pH: #{soil_parameters['ph']}" if soil_parameters['ph']
    parts << "Органика: #{soil_parameters['organic_matter']}%" if soil_parameters['organic_matter']
    parts << "N: #{soil_parameters['nitrogen']} мг/кг" if soil_parameters['nitrogen']

    parts.any? ? parts.join(' | ') : 'Данные доступны'
  end

  # Get plant state summary
  def plant_state_summary
    return 'Нет данных' unless plant_state.present? && plant_state.is_a?(Hash)

    parts = []
    parts << "Стадия: #{plant_state['growth_stage']}" if plant_state['growth_stage']
    parts << "Биомасса: #{plant_state['biomass']} т/га" if plant_state['biomass']
    parts << "Здоровье: #{plant_state['health_index']}" if plant_state['health_index']

    parts.any? ? parts.join(' | ') : 'Данные доступны'
  end

  # Compare prediction with actual yield (for model validation)
  def compare_with_actual(actual_yield)
    return nil unless predicted_yield.present? && actual_yield.present?

    difference = actual_yield - predicted_yield
    percent_error = ((difference / predicted_yield).abs * 100).round(2)

    {
      difference: difference.round(2),
      percent_error: percent_error,
      accuracy: (100 - percent_error).round(2)
    }
  end

  # Check if prediction is still valid
  def is_current?
    return false unless prediction_date.present?

    prediction_date >= 14.days.ago
  end

  # Get summary for display
  def summary
    "#{model_type_ru}: #{predicted_yield_with_unit}, #{quality_description}, #{confidence_description}"
  end
end
