class CreateProcessSteps < ActiveRecord::Migration[8.0]
  def change
    create_table :process_steps do |t|
      t.references :process, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :step_type, null: false # action, decision, agent_task, integration, etc.
      t.integer :order, null: false
      t.json :configuration, default: {}
      t.json :input_schema, default: {}
      t.json :output_schema, default: {}
      t.integer :next_step_id # For linear flow
      t.json :conditions, default: {} # For conditional branching

      t.timestamps
    end

    add_index :process_steps, [:process_id, :order]
    add_index :process_steps, :step_type
  end
end
