# Decision Support System (СППР) for Agricultural Management
# Based on conceptual materials from issue #58 - intelligent decision making
# Integrates Plant-Soil-Atmosphere modeling and multi-agent recommendations
class CreateDecisionSupportTables < ActiveRecord::Migration[8.1]
  def change
    # DecisionSupports - recommendations from the decision support system
    create_table :decision_supports do |t|
      t.references :farm, foreign_key: true, null: false
      t.references :crop, foreign_key: true
      t.references :field_zone, foreign_key: true
      t.references :agro_agent, foreign_key: true # agent that generated this decision

      t.string :decision_type, null: false # planting_schedule, fertilization_plan, irrigation_schedule, pest_control, harvest_timing
      t.string :status, default: 'pending' # pending, under_review, approved, rejected, executed
      t.text :input_data # JSON - data used for decision making
      t.text :analysis_result # JSON - analysis output
      t.text :recommendations # JSON - structured recommendations
      t.text :reasoning # explanation of the decision
      t.float :confidence_score # 0-100, confidence in recommendation
      t.integer :priority, default: 2 # 0: low, 1: normal, 2: high, 3: critical
      t.datetime :recommended_execution_date
      t.datetime :executed_at
      t.text :execution_result # JSON - outcome of executing the recommendation

      t.timestamps
    end

    # PlantProductionModels - mathematical models for crop yield prediction
    # Implementation of Plant-Soil-Atmosphere (PSA) model
    create_table :plant_production_models do |t|
      t.references :crop, foreign_key: true, null: false
      t.references :field_zone, foreign_key: true
      t.references :agrotechnology_ontology, foreign_key: true

      t.string :model_type, null: false # psa_model, regression, machine_learning
      t.string :model_version
      t.text :weather_data # JSON - historical and forecast weather
      t.text :soil_parameters # JSON - pH, nutrients, moisture, temperature
      t.text :plant_state # JSON - growth stage, biomass, health indicators
      t.text :management_practices # JSON - fertilization, irrigation applied
      t.float :predicted_yield # tons/ha
      t.float :predicted_quality # quality score
      t.date :harvest_date_prediction
      t.float :confidence_level # 0-100
      t.datetime :prediction_date
      t.text :model_parameters # JSON - coefficients, weights

      t.timestamps
    end

    # SimulationResults - results from AGROTOOL-like simulation system
    # Scenario modeling and optimization
    create_table :simulation_results do |t|
      t.references :farm, foreign_key: true, null: false
      t.references :crop, foreign_key: true
      t.references :adaptive_agrotechnology, foreign_key: true

      t.string :simulation_type, null: false # yield_optimization, cost_minimization, risk_assessment
      t.text :scenario_parameters # JSON - input variables
      t.text :simulation_data # JSON - detailed simulation output
      t.float :predicted_outcome # main outcome metric
      t.float :economic_benefit # estimated profit, rubles
      t.float :environmental_impact_score # sustainability metric
      t.string :recommendation_summary
      t.datetime :simulated_at

      t.timestamps
    end

    # KnowledgeBaseEntries - agricultural knowledge base
    # Ontological knowledge representation for decision support
    create_table :knowledge_base_entries do |t|
      t.string :category, null: false # crop_management, pest_disease, soil_health, weather_patterns
      t.string :entry_type, null: false # fact, rule, case_study, best_practice
      t.string :title, null: false
      t.text :content
      t.text :ontology_link # RDF/OWL reference to ontology
      t.text :related_concepts # JSON - links to other entries
      t.text :applicability_conditions # JSON - when this knowledge applies
      t.integer :confidence_level, default: 5 # 1-10 scale
      t.string :source # research paper, expert, historical data
      t.string :language, default: 'ru'

      t.timestamps
    end

    # RiskAssessments - risk analysis for agricultural operations
    create_table :risk_assessments do |t|
      t.references :farm, foreign_key: true, null: false
      t.references :crop, foreign_key: true
      t.references :decision_support, foreign_key: true

      t.string :risk_type, null: false # weather, pest, market, operational
      t.string :severity, null: false # low, medium, high, critical
      t.float :probability # 0-100
      t.float :impact_score # estimated loss, rubles
      t.text :risk_description
      t.text :mitigation_strategies # JSON - recommended actions
      t.date :assessment_date
      t.boolean :is_active, default: true

      t.timestamps
    end

    # Indexes for efficient querying
    add_index :decision_supports, [:farm_id, :status]
    add_index :decision_supports, [:decision_type, :status]
    add_index :decision_supports, :recommended_execution_date
    add_index :plant_production_models, [:crop_id, :prediction_date]
    add_index :simulation_results, [:farm_id, :simulation_type]
    add_index :knowledge_base_entries, [:category, :entry_type]
    add_index :risk_assessments, [:farm_id, :is_active]
    add_index :risk_assessments, [:severity, :is_active]
  end
end
