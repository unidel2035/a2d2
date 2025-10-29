# Agrotechnology Ontology System
# Based on conceptual materials from issue #58 - ontological structuring of agrotechnological knowledge
# Implements 11 production cycle processes from Yakushev's framework
class CreateAgrotechnologyOntologyTables < ActiveRecord::Migration[8.1]
  def change
    # AgrotechnologyOntologies - base agrotechnology templates (БАТ - Базовые Агротехнологии)
    create_table :agrotechnology_ontologies do |t|
      t.string :name, null: false
      t.string :crop_type, null: false
      t.string :soil_type
      t.string :climate_zone
      t.text :description
      t.integer :version, default: 1
      t.text :ontology_data # JSON/RDF - formal ontological representation
      t.boolean :is_template, default: true # base technology vs adapted
      t.references :parent_ontology, foreign_key: { to_table: :agrotechnology_ontologies }

      t.timestamps
    end

    # AgrotechnologyOperations - individual operations in production cycle
    # Based on 11 processes: soil cultivation, fertilization, seed prep, sowing,
    # plant care, plant protection, harvesting, post-harvest, storage, prep for sale, sale
    create_table :agrotechnology_operations do |t|
      t.references :agrotechnology_ontology, foreign_key: true, null: false
      t.string :name, null: false
      t.integer :operation_type, null: false # 0-10 for the 11 production cycle processes
      t.integer :sequence_order, null: false
      t.text :description
      t.text :parameters # JSON - temperature, depth, rate, etc.
      t.text :conditions # JSON - weather requirements, timing constraints
      t.text :equipment_requirements # JSON - required machinery
      t.text :material_requirements # JSON - seeds, fertilizers, pesticides
      t.integer :duration_days # estimated duration
      t.string :quality_criteria # success metrics

      t.timestamps
    end

    # AdaptiveAgrotechnologies - farm-specific adapted technologies (ААТ)
    # Adaptation of base technology to specific conditions
    create_table :adaptive_agrotechnologies do |t|
      t.references :agrotechnology_ontology, foreign_key: true, null: false
      t.references :farm, foreign_key: true, null: false
      t.references :crop, foreign_key: true
      t.references :field_zone, foreign_key: true

      t.string :name, null: false
      t.text :adaptations # JSON - modifications from base technology
      t.text :execution_plan # JSON - scheduled operations
      t.string :status, default: 'planned' # planned, active, completed
      t.date :start_date
      t.date :end_date
      t.text :performance_metrics # JSON - actual vs expected

      t.timestamps
    end

    # AgrotechnologyParameters - parameters for Variable Rate Technology (VRT)
    # Differential application rates for precision agriculture
    create_table :agrotechnology_parameters do |t|
      t.references :agrotechnology_operation, foreign_key: true
      t.references :field_zone, foreign_key: true

      t.string :parameter_name, null: false # fertilizer_rate, seed_density, etc.
      t.float :value, null: false
      t.string :unit, null: false # kg/ha, seeds/m², etc.
      t.text :justification # JSON - why this value (based on soil, NDVI, etc.)
      t.string :application_method # broadcast, precision, variable_rate

      t.timestamps
    end

    # Indexes for efficient querying
    add_index :agrotechnology_ontologies, [:crop_type, :is_template]
    add_index :agrotechnology_operations, [:agrotechnology_ontology_id, :sequence_order]
    add_index :agrotechnology_operations, :operation_type
    add_index :adaptive_agrotechnologies, [:farm_id, :status]
    add_index :adaptive_agrotechnologies, [:crop_id, :status]
    add_index :agrotechnology_parameters, [:agrotechnology_operation_id]
  end
end
