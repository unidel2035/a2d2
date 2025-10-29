class CreateNotificationLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :notification_logs do |t|
      # Polymorphic association
      t.references :notifiable, polymorphic: true, null: false, index: true

      # Тип уведомления (maintenance_reminder, deadline_alert, etc.)
      t.string :notification_type, null: false

      # Получатели уведомления (JSON array)
      t.text :recipients

      # Дополнительные данные
      t.integer :days_before
      t.date :scheduled_date
      t.datetime :sent_at, null: false

      # Метаданные (JSON)
      t.text :metadata

      t.timestamps
    end

    add_index :notification_logs, :notification_type
    add_index :notification_logs, :sent_at
    add_index :notification_logs, :scheduled_date
  end
end
