class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    # Создаем таблицу только если она не существует
    create_table :audit_logs, if_not_exists: true do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action, null: false
      t.string :resource_type
      t.bigint :resource_id
      t.text :details
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end

    # Создаем индексы только если они не существуют
    add_index :audit_logs, :user_id, if_not_exists: true
    add_index :audit_logs, :action, if_not_exists: true
    add_index :audit_logs, [:resource_type, :resource_id], if_not_exists: true
    add_index :audit_logs, :created_at, if_not_exists: true
  end
end
