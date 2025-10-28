# AgrotechnologyOntology - Base agrotechnology templates (БАТ - Базовые Агротехнологии)
# Ontological representation of agricultural technologies
# Based on conceptual materials: Yakushev V.V. - structuring agrotechnological knowledge
class AgrotechnologyOntology < ApplicationRecord
  belongs_to :parent_ontology, class_name: 'AgrotechnologyOntology', optional: true
  has_many :child_ontologies, class_name: 'AgrotechnologyOntology', foreign_key: 'parent_ontology_id'
  has_many :agrotechnology_operations, dependent: :destroy
  has_many :adaptive_agrotechnologies, dependent: :destroy
  has_many :plant_production_models, dependent: :nullify

  validates :name, presence: true
  validates :crop_type, presence: true
  validates :version, numericality: { only_integer: true, greater_than: 0 }

  serialize :ontology_data, coder: JSON

  scope :templates, -> { where(is_template: true) }
  scope :for_crop, ->(crop_type) { where(crop_type: crop_type) }
  scope :for_soil, ->(soil_type) { where(soil_type: soil_type) }
  scope :latest_versions, -> { order(version: :desc) }

  # Get all operations in sequence
  def ordered_operations
    agrotechnology_operations.order(:sequence_order)
  end

  # Get operations by production cycle stage
  def operations_by_type(operation_type)
    agrotechnology_operations.where(operation_type: operation_type)
  end

  # Create adapted version for specific farm
  def adapt_for_farm(farm, adaptations = {})
    adaptive_agrotechnologies.create(
      farm: farm,
      name: "#{name} (адаптированная для #{farm.name})",
      adaptations: adaptations,
      status: 'planned'
    )
  end

  # Get full technology description
  def full_description
    description_parts = [description]
    description_parts << "Культура: #{crop_type}"
    description_parts << "Тип почвы: #{soil_type}" if soil_type.present?
    description_parts << "Климатическая зона: #{climate_zone}" if climate_zone.present?
    description_parts << "Операций: #{agrotechnology_operations.count}"

    description_parts.compact.join(' | ')
  end

  # Get ontology summary for RDF/OWL export
  def ontology_summary
    {
      uri: "agro:ontology:#{id}",
      name: name,
      crop: crop_type,
      soil: soil_type,
      climate: climate_zone,
      operations: ordered_operations.map(&:operation_summary),
      version: version
    }
  end

  # Clone ontology for new version
  def create_new_version
    new_ontology = dup
    new_ontology.version = version + 1
    new_ontology.is_template = true

    if new_ontology.save
      agrotechnology_operations.each do |operation|
        new_operation = operation.dup
        new_operation.agrotechnology_ontology = new_ontology
        new_operation.save
      end
    end

    new_ontology
  end
end
