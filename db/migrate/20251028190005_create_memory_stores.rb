class CreateMemoryStores < ActiveRecord::Migration[8.1]
  def change
    create_table :memory_stores do |t|
      t.references :agent, null: false, foreign_key: true
      t.string :memory_type, null: false  # 'context', 'long_term', 'shared'
      t.string :key, null: false
      t.text :value
      t.text :metadata
      t.datetime :expires_at
      t.integer :access_count, default: 0
      t.datetime :last_accessed_at
      t.integer :priority, default: 0
      t.integer :size_bytes, default: 0

      t.timestamps
    end

    add_index :memory_stores, [:agent_id, :memory_type, :key], unique: true, name: 'index_memory_stores_on_agent_type_key'
    add_index :memory_stores, :memory_type
    add_index :memory_stores, :expires_at
    add_index :memory_stores, :last_accessed_at
    add_index :memory_stores, :priority
  end
end
