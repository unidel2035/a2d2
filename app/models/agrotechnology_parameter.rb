# AgrotechnologyParameter - Parameters for Variable Rate Technology (VRT)
# Differential application rates for precision agriculture
# Enables zone-specific parameterization of operations
class AgrotechnologyParameter < ApplicationRecord
  belongs_to :agrotechnology_operation
  belongs_to :field_zone, optional: true

  validates :parameter_name, presence: true
  validates :value, presence: true, numericality: true
  validates :unit, presence: true

  serialize :justification, coder: JSON

  APPLICATION_METHODS = %w[broadcast precision variable_rate spot_treatment].freeze

  validates :application_method, inclusion: { in: APPLICATION_METHODS }, allow_nil: true

  scope :for_operation, ->(operation_id) { where(agrotechnology_operation_id: operation_id) }
  scope :for_zone, ->(zone_id) { where(field_zone_id: zone_id) }
  scope :variable_rate, -> { where(application_method: 'variable_rate') }

  # Get human-readable description
  def description
    "#{parameter_name}: #{value} #{unit}"
  end

  # Get full description with justification
  def full_description
    desc = [description]
    desc << "Метод: #{application_method_ru}" if application_method.present?
    desc << "Зона: #{field_zone.name}" if field_zone.present?

    if justification.present? && justification.is_a?(Hash)
      reasons = justification.dig('reasons')
      desc << "Обоснование: #{reasons.join(', ')}" if reasons.is_a?(Array)
    end

    desc.join(' | ')
  end

  # Get application method in Russian
  def application_method_ru
    case application_method
    when 'broadcast'
      'Сплошное внесение'
    when 'precision'
      'Точное внесение'
    when 'variable_rate'
      'Дифференцированное внесение (VRT)'
    when 'spot_treatment'
      'Очаговая обработка'
    else
      application_method.to_s.humanize
    end
  end

  # Compare with another parameter (for optimization)
  def compare_with(other_parameter)
    return nil unless other_parameter.is_a?(AgrotechnologyParameter)
    return nil unless unit == other_parameter.unit

    {
      difference: value - other_parameter.value,
      percent_change: ((value - other_parameter.value) / other_parameter.value * 100).round(2)
    }
  end

  # Calculate total amount needed for zone
  def total_amount_for_zone
    return nil unless field_zone.present? && field_zone.area.present?

    value * field_zone.area
  end

  # Get justification summary
  def justification_summary
    return 'Нет обоснования' unless justification.present? && justification.is_a?(Hash)

    parts = []
    parts << "NDVI: #{justification['ndvi']}" if justification['ndvi']
    parts << "Тип почвы: #{justification['soil_type']}" if justification['soil_type']
    parts << "История поля: #{justification['historical_data']}" if justification['historical_data']

    parts.any? ? parts.join(', ') : 'Обоснование доступно'
  end
end
