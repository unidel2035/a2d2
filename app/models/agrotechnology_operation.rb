# AgrotechnologyOperation - Individual operations in production cycle
# Based on 11 production cycle processes from Yakushev's framework:
# 1. Основная обработка почвы (Main soil cultivation)
# 2. Внесение удобрений (Fertilizer application)
# 3. Подготовка семян (Seed preparation)
# 4. Предпосевная обработка и посев (Pre-sowing and sowing)
# 5. Уход за растениями (Plant care)
# 6. Защита растений (Plant protection)
# 7. Уборка урожая (Harvesting)
# 8. Послеуборочная обработка (Post-harvest processing)
# 9. Хранение (Storage)
# 10. Подготовка к реализации (Preparation for sale)
# 11. Реализация (Sale)
class AgrotechnologyOperation < ApplicationRecord
  belongs_to :agrotechnology_ontology
  has_many :agrotechnology_parameters, dependent: :destroy

  # 11 production cycle processes
  enum operation_type: {
    soil_preparation: 0,
    fertilization: 1,
    seed_preparation: 2,
    pre_sowing: 3,
    plant_care: 4,
    plant_protection: 5,
    harvesting: 6,
    post_harvest: 7,
    storage: 8,
    preparation_for_sale: 9,
    sale: 10
  }

  validates :name, presence: true
  validates :operation_type, presence: true
  validates :sequence_order, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :sequence_order, uniqueness: { scope: :agrotechnology_ontology_id }

  serialize :parameters, coder: JSON
  serialize :conditions, coder: JSON
  serialize :equipment_requirements, coder: JSON
  serialize :material_requirements, coder: JSON

  scope :ordered, -> { order(:sequence_order) }
  scope :by_type, ->(type) { where(operation_type: type) }

  # Get human-readable operation type name in Russian
  def operation_type_name_ru
    case operation_type
    when 'soil_preparation'
      'Основная обработка почвы'
    when 'fertilization'
      'Внесение удобрений'
    when 'seed_preparation'
      'Подготовка семян'
    when 'pre_sowing'
      'Предпосевная обработка и посев'
    when 'plant_care'
      'Уход за растениями'
    when 'plant_protection'
      'Защита растений'
    when 'harvesting'
      'Уборка урожая'
    when 'post_harvest'
      'Послеуборочная обработка'
    when 'storage'
      'Хранение'
    when 'preparation_for_sale'
      'Подготовка к реализации'
    when 'sale'
      'Реализация'
    else
      operation_type.to_s.humanize
    end
  end

  # Get operation summary for ontology export
  def operation_summary
    {
      uri: "agro:operation:#{id}",
      name: name,
      type: operation_type,
      type_ru: operation_type_name_ru,
      sequence: sequence_order,
      duration_days: duration_days,
      equipment: equipment_requirements || [],
      materials: material_requirements || []
    }
  end

  # Check if operation requires specific equipment
  def requires_equipment?(equipment_type)
    equipment_requirements&.include?(equipment_type)
  end

  # Get parameters for specific field zone (Variable Rate Technology)
  def parameters_for_zone(field_zone)
    agrotechnology_parameters.where(field_zone: field_zone).first
  end

  # Check if conditions are met for execution
  def conditions_met?(current_conditions)
    return true if conditions.blank?

    conditions.all? do |key, required_value|
      current_conditions[key] == required_value
    end
  end

  # Estimate cost of operation
  def estimated_cost
    material_cost = calculate_material_cost
    equipment_cost = calculate_equipment_cost
    labor_cost = calculate_labor_cost

    material_cost + equipment_cost + labor_cost
  end

  private

  def calculate_material_cost
    return 0 unless material_requirements.present?

    # Simplified calculation - would need actual pricing data
    material_requirements.sum { |_material, quantity| quantity.to_f * 100 }
  end

  def calculate_equipment_cost
    return 0 unless equipment_requirements.present? && duration_days.present?

    # Simplified calculation - would need actual rental/operation costs
    equipment_requirements.count * duration_days * 5000
  end

  def calculate_labor_cost
    return 0 unless duration_days.present?

    # Simplified calculation - would need actual labor rates
    duration_days * 2000
  end
end
