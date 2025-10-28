# DecisionSupport - Recommendations from the Decision Support System (СППР)
# Intelligent decision making for agricultural management
# Based on conceptual materials: multi-agent decision support approach
class DecisionSupport < ApplicationRecord
  belongs_to :farm
  belongs_to :crop, optional: true
  belongs_to :field_zone, optional: true
  belongs_to :agro_agent, optional: true
  has_many :risk_assessments, dependent: :nullify

  DECISION_TYPES = %w[
    planting_schedule
    fertilization_plan
    irrigation_schedule
    pest_control
    harvest_timing
    soil_preparation
    crop_rotation
    resource_allocation
  ].freeze

  STATUSES = %w[pending under_review approved rejected executed].freeze
  PRIORITIES = [0, 1, 2, 3] # low, normal, high, critical

  validates :decision_type, presence: true, inclusion: { in: DECISION_TYPES }
  validates :status, inclusion: { in: STATUSES }
  validates :priority, inclusion: { in: PRIORITIES }
  validates :confidence_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  serialize :input_data, coder: JSON
  serialize :analysis_result, coder: JSON
  serialize :recommendations, coder: JSON
  serialize :execution_result, coder: JSON

  scope :pending, -> { where(status: 'pending') }
  scope :under_review, -> { where(status: 'under_review') }
  scope :approved, -> { where(status: 'approved') }
  scope :executed, -> { where(status: 'executed') }
  scope :high_priority, -> { where(priority: [2, 3]) }
  scope :high_confidence, -> { where('confidence_score >= ?', 80) }
  scope :recent, -> { where('created_at >= ?', 30.days.ago) }
  scope :for_execution, -> { where(status: 'approved').where('recommended_execution_date <= ?', Date.current) }

  # Approve decision for execution
  def approve!
    update(status: 'approved')
  end

  # Reject decision
  def reject!(reason = nil)
    update(status: 'rejected', reasoning: "#{reasoning}\nОтклонено: #{reason}".strip)
  end

  # Mark as executed with results
  def execute!(result = {})
    update(
      status: 'executed',
      executed_at: Time.current,
      execution_result: result
    )
  end

  # Get decision type in Russian
  def decision_type_ru
    case decision_type
    when 'planting_schedule'
      'График посева'
    when 'fertilization_plan'
      'План внесения удобрений'
    when 'irrigation_schedule'
      'График полива'
    when 'pest_control'
      'Защита от вредителей'
    when 'harvest_timing'
      'Сроки уборки'
    when 'soil_preparation'
      'Подготовка почвы'
    when 'crop_rotation'
      'Севооборот'
    when 'resource_allocation'
      'Распределение ресурсов'
    else
      decision_type.humanize
    end
  end

  # Get priority in Russian
  def priority_ru
    case priority
    when 0
      'Низкий'
    when 1
      'Нормальный'
    when 2
      'Высокий'
    when 3
      'Критический'
    else
      'Не определен'
    end
  end

  # Get confidence level classification
  def confidence_level
    return 'Не определен' unless confidence_score.present?

    case confidence_score
    when 90..100
      'Очень высокая'
    when 75..89
      'Высокая'
    when 60..74
      'Средняя'
    when 40..59
      'Низкая'
    else
      'Очень низкая'
    end
  end

  # Check if decision is time-sensitive
  def time_sensitive?
    return false unless recommended_execution_date.present?

    recommended_execution_date <= 3.days.from_now.to_date
  end

  # Get summary of recommendations
  def recommendations_summary
    return 'Нет рекомендаций' unless recommendations.present?

    if recommendations.is_a?(Array)
      recommendations.first(3).join('; ')
    elsif recommendations.is_a?(Hash)
      recommendations.dig('summary') || 'Рекомендации доступны'
    else
      'Рекомендации доступны'
    end
  end

  # Get analysis summary
  def analysis_summary
    return 'Анализ не проведен' unless analysis_result.present? && analysis_result.is_a?(Hash)

    parts = []
    parts << "Факторов: #{analysis_result['factors_analyzed']}" if analysis_result['factors_analyzed']
    parts << "Источников данных: #{analysis_result['data_sources']}" if analysis_result['data_sources']
    parts << "Метод: #{analysis_result['method']}" if analysis_result['method']

    parts.any? ? parts.join(' | ') : 'Анализ завершен'
  end

  # Check if execution is overdue
  def overdue?
    return false unless recommended_execution_date.present?
    return false if executed?

    recommended_execution_date < Date.current
  end

  # Get days until execution
  def days_until_execution
    return nil unless recommended_execution_date.present?
    return 0 if executed?

    (recommended_execution_date - Date.current).to_i
  end
end
