# RiskAssessment - Risk analysis for agricultural operations
# Part of decision support system for proactive risk management
# Based on conceptual materials: risk-aware decision making
class RiskAssessment < ApplicationRecord
  belongs_to :farm
  belongs_to :crop, optional: true
  belongs_to :decision_support, optional: true

  RISK_TYPES = %w[
    weather
    pest
    disease
    market
    operational
    financial
    regulatory
    equipment_failure
  ].freeze

  SEVERITIES = %w[low medium high critical].freeze

  validates :risk_type, presence: true, inclusion: { in: RISK_TYPES }
  validates :severity, presence: true, inclusion: { in: SEVERITIES }
  validates :probability, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  serialize :mitigation_strategies, coder: JSON

  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }
  scope :by_type, ->(type) { where(risk_type: type) }
  scope :by_severity, ->(severity) { where(severity: severity) }
  scope :critical, -> { where(severity: 'critical') }
  scope :high_severity, -> { where(severity: %w[high critical]) }
  scope :high_probability, -> { where('probability >= ?', 70) }
  scope :recent, -> { where('assessment_date >= ?', 90.days.ago) }

  # Calculate risk score (probability × impact)
  def risk_score
    return nil unless probability.present? && impact_score.present?

    (probability / 100.0 * impact_score).round(2)
  end

  # Get risk level based on score
  def risk_level
    score = risk_score
    return 'Не определен' unless score

    case score
    when 0..1000
      'Низкий'
    when 1001..5000
      'Средний'
    when 5001..10000
      'Высокий'
    else
      'Критический'
    end
  end

  # Get risk type in Russian
  def risk_type_ru
    case risk_type
    when 'weather'
      'Погодный риск'
    when 'pest'
      'Риск вредителей'
    when 'disease'
      'Риск заболеваний'
    when 'market'
      'Рыночный риск'
    when 'operational'
      'Операционный риск'
    when 'financial'
      'Финансовый риск'
    when 'regulatory'
      'Регуляторный риск'
    when 'equipment_failure'
      'Риск отказа техники'
    else
      risk_type.humanize
    end
  end

  # Get severity in Russian
  def severity_ru
    case severity
    when 'low'
      'Низкая'
    when 'medium'
      'Средняя'
    when 'high'
      'Высокая'
    when 'critical'
      'Критическая'
    else
      severity.humanize
    end
  end

  # Get impact formatted
  def impact_formatted
    return 'Не определено' unless impact_score.present?

    "#{impact_score.round(2)} руб."
  end

  # Get probability description
  def probability_description
    return 'Не определена' unless probability.present?

    case probability
    when 80..100
      'Очень высокая вероятность'
    when 60..79
      'Высокая вероятность'
    when 40..59
      'Средняя вероятность'
    when 20..39
      'Низкая вероятность'
    else
      'Очень низкая вероятность'
    end
  end

  # Get mitigation strategies summary
  def mitigation_summary
    return 'Нет стратегий' unless mitigation_strategies.present?

    if mitigation_strategies.is_a?(Array)
      "#{mitigation_strategies.count} стратегий: #{mitigation_strategies.first(2).join(', ')}"
    elsif mitigation_strategies.is_a?(Hash)
      strategies = mitigation_strategies.dig('strategies')
      strategies.is_a?(Array) ? "#{strategies.count} стратегий" : 'Стратегии доступны'
    else
      'Стратегии доступны'
    end
  end

  # Deactivate risk
  def deactivate!(reason = nil)
    update(
      is_active: false,
      risk_description: "#{risk_description}\nДеактивировано: #{reason}".strip
    )
  end

  # Reactivate risk
  def activate!
    update(is_active: true)
  end

  # Check if risk requires immediate attention
  def requires_immediate_attention?
    is_active && (severity == 'critical' || (severity == 'high' && probability.to_i >= 70))
  end

  # Get days since assessment
  def days_since_assessment
    return nil unless assessment_date.present?

    (Date.current - assessment_date).to_i
  end

  # Check if assessment is outdated
  def outdated?
    return false unless assessment_date.present?

    assessment_date < 60.days.ago
  end

  # Get full summary
  def summary
    [
      risk_type_ru,
      "Вероятность: #{probability}%",
      "Ущерб: #{impact_formatted}",
      "Уровень: #{risk_level}"
    ].join(' | ')
  end

  # Get risk matrix position (for visualization)
  def matrix_position
    {
      probability: probability_category,
      impact: impact_category
    }
  end

  private

  def probability_category
    return nil unless probability.present?

    case probability
    when 0..20 then 'very_low'
    when 21..40 then 'low'
    when 41..60 then 'medium'
    when 61..80 then 'high'
    else 'very_high'
    end
  end

  def impact_category
    return nil unless impact_score.present?

    case impact_score
    when 0..1000 then 'very_low'
    when 1001..5000 then 'low'
    when 5001..10000 then 'medium'
    when 10001..50000 then 'high'
    else 'very_high'
    end
  end
end
