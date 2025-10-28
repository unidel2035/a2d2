# frozen_string_literal: true

class CreateWorkflows < ActiveRecord::Migration[8.1]
  def change
    create_table :workflows do |t|
      t.string :name, null: false
      t.string :status, default: 'inactive', null: false
      t.text :settings
      t.text :static_data
      t.text :tags
      t.references :user, foreign_key: true
      t.references :project, foreign_key: false

      t.timestamps
    end

    add_index :workflows, :name
    add_index :workflows, :status
  end
end
