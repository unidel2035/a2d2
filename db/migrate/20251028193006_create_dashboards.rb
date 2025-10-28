class CreateDashboards < ActiveRecord::Migration[8.0]
  def change
    create_table :dashboards do |t|
      t.string :name, null: false
      t.text :description
      t.json :configuration, default: {}
      t.json :widgets, default: [] # Array of widget configurations
      t.references :user, null: false, foreign_key: true
      t.boolean :is_public, default: false
      t.integer :refresh_interval, default: 60 # seconds

      t.timestamps
    end

    add_index :dashboards, :name
    add_index :dashboards, :is_public
  end
end
