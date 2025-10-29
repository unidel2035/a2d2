# frozen_string_literal: true

class CreateTokenBlacklists < ActiveRecord::Migration[8.1]
  def change
    create_table :token_blacklists do |t|
      t.string :jti, null: false
      t.references :user, null: false, foreign_key: true
      t.datetime :expires_at, null: false

      t.timestamps
    end

    add_index :token_blacklists, :jti, unique: true
    add_index :token_blacklists, :expires_at
  end
end
