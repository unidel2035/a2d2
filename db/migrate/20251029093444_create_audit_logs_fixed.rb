class CreateAuditLogsFixed < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs_fixeds do |t|
      t.timestamps
    end
  end
end
