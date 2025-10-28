class CreateAgroPlatformTables < ActiveRecord::Migration[8.1]
  def change
    # AgroAgents - multi-agent system for agricultural ecosystem
    create_table :agro_agents do |t|
      t.string :name, null: false
      t.string :agent_type, null: false # farmer, logistics, processor, retailer, regulator
      t.string :level, null: false # iot_layer, micro_meso, macro
      t.string :status, default: 'active' # active, inactive, offline
      t.text :capabilities # JSON array of capabilities
      t.text :configuration # JSON configuration
      t.datetime :last_heartbeat
      t.integer :tasks_completed, default: 0
      t.integer :tasks_failed, default: 0
      t.float :success_rate, default: 100.0
      t.references :user, foreign_key: true # owner/operator

      t.timestamps
    end

    # AgroTasks - tasks for agents
    create_table :agro_tasks do |t|
      t.references :agro_agent, foreign_key: true
      t.string :task_type, null: false
      t.string :priority, default: 'normal' # low, normal, high, critical
      t.string :status, default: 'pending' # pending, in_progress, completed, failed
      t.text :input_data # JSON
      t.text :output_data # JSON
      t.text :error_message
      t.datetime :started_at
      t.datetime :completed_at
      t.integer :retry_count, default: 0

      t.timestamps
    end

    # Farms - agricultural enterprises
    create_table :farms do |t|
      t.string :name, null: false
      t.string :farm_type # crop, livestock, mixed, processing
      t.string :location
      t.float :area # hectares
      t.text :coordinates # JSON
      t.references :agro_agent, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end

    # Crops - agricultural products
    create_table :crops do |t|
      t.references :farm, foreign_key: true
      t.string :crop_type, null: false # wheat, corn, vegetables, etc.
      t.string :season
      t.float :area_planted # hectares
      t.float :expected_yield # tons
      t.float :actual_yield # tons
      t.date :planting_date
      t.date :harvest_date
      t.string :status, default: 'planning' # planning, planted, growing, harvesting, harvested

      t.timestamps
    end

    # Equipment - agricultural machinery
    create_table :equipment do |t|
      t.references :farm, foreign_key: true
      t.string :name, null: false
      t.string :equipment_type # tractor, harvester, drone, sensor
      t.string :model
      t.string :status, default: 'available' # available, in_use, maintenance, offline
      t.boolean :autonomous, default: false
      t.text :telemetry_data # JSON - latest IoT data
      t.datetime :last_telemetry_at

      t.timestamps
    end

    # LogisticsOrders - transportation and logistics
    create_table :logistics_orders do |t|
      t.references :agro_agent, foreign_key: true
      t.string :order_type, null: false # transport, storage, delivery
      t.string :status, default: 'pending' # pending, assigned, in_transit, delivered, cancelled
      t.text :origin # JSON
      t.text :destination # JSON
      t.float :quantity # tons
      t.string :product_type
      t.datetime :pickup_time
      t.datetime :delivery_time
      t.text :route_data # JSON

      t.timestamps
    end

    # ProcessingBatches - product processing tracking
    create_table :processing_batches do |t|
      t.references :agro_agent, foreign_key: true
      t.string :batch_number, null: false
      t.string :input_product
      t.string :output_product
      t.float :input_quantity
      t.float :output_quantity
      t.string :status, default: 'planned' # planned, processing, completed, quality_check
      t.datetime :started_at
      t.datetime :completed_at
      t.text :quality_metrics # JSON

      t.timestamps
    end

    # MarketOffers - demand and supply marketplace
    create_table :market_offers do |t|
      t.references :agro_agent, foreign_key: true
      t.string :offer_type, null: false # supply, demand
      t.string :product_type, null: false
      t.float :quantity
      t.string :unit # tons, kg, liters
      t.decimal :price_per_unit, precision: 10, scale: 2
      t.string :status, default: 'active' # active, matched, completed, cancelled
      t.date :valid_until
      t.text :conditions # JSON

      t.timestamps
    end

    # SmartContracts - automated agreements
    create_table :smart_contracts do |t|
      t.references :buyer_agent, foreign_key: { to_table: :agro_agents }
      t.references :seller_agent, foreign_key: { to_table: :agro_agents }
      t.string :contract_type, null: false
      t.string :status, default: 'draft' # draft, active, fulfilled, disputed, cancelled
      t.text :terms # JSON
      t.decimal :total_amount, precision: 12, scale: 2
      t.date :execution_date
      t.date :completion_date
      t.text :fulfillment_data # JSON

      t.timestamps
    end

    # AgentCoordinations - multi-agent orchestration
    create_table :agent_coordinations do |t|
      t.string :coordination_type, null: false # workflow, negotiation, optimization
      t.string :status, default: 'active' # active, completed, failed
      t.text :participating_agents # JSON array of agent IDs
      t.text :coordination_data # JSON
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :agro_agents, :agent_type
    add_index :agro_agents, :level
    add_index :agro_agents, :status
    add_index :agro_tasks, :status
    add_index :agro_tasks, :priority
    add_index :crops, :status
    add_index :equipment, :status
    add_index :logistics_orders, :status
    add_index :processing_batches, :status
    add_index :market_offers, :status
    add_index :smart_contracts, :status
  end
end
