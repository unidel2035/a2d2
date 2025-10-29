class CreateReports < ActiveRecord::Migration[8.0]
  def change
    create_table :reports do |t|
      t.string :name, null: false
      t.text :description
      t.string :report_type, null: false # pdf, excel, csv
      t.json :parameters, default: {}
      t.json :schedule, default: {} # Cron-like schedule
      t.references :user, null: false, foreign_key: true
      t.datetime :last_generated_at
      t.datetime :next_generation_at
      t.integer :status, default: 0, null: false # inactive, active, generating, failed

      t.timestamps
    end

    add_index :reports, :status
    add_index :reports, :report_type
    add_index :reports, :next_generation_at
  end
end
