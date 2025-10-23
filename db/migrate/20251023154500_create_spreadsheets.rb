class CreateSpreadsheets < ActiveRecord::Migration[8.1]
  def change
    create_table :spreadsheets do |t|
      t.string :name, null: false
      t.text :description
      t.integer :owner_id
      t.json :settings, default: {}
      t.boolean :public, default: false
      t.string :share_token

      t.timestamps

      t.index :owner_id
      t.index :share_token, unique: true
    end
  end
end
