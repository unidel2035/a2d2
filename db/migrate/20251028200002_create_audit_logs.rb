# frozen_string_literal: true

# Create audit_logs table
# AUD-001: Audit trail of all critical operations
# AUD-002: User activity logging
# AUD-003: Tamper-proof logs with checksums
# AUD-005: Log retention policies
class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs do |t|
      # User who performed the action
      t.references :user, foreign_key: true

      # Action details
      t.string :action, null: false # create, read, update, delete, login, logout, etc.
      t.string :auditable_type, null: false # Model name
      t.bigint :auditable_id # Record ID
      t.text :changes # JSON of changes made
      t.string :ip_address
      t.string :user_agent
      t.string :request_id

      # Tamper-proof checksum (AUD-003)
      t.string :checksum, null: false

      # Previous log checksum for chain integrity
      t.string :previous_checksum

      # Metadata
      t.text :metadata # Additional context as JSON
      t.string :status # success, failure
      t.text :error_message # If failed

      # Timestamps
      t.datetime :created_at, null: false
    end

    add_index :audit_logs, :user_id
    add_index :audit_logs, [:auditable_type, :auditable_id]
    add_index :audit_logs, :action
    add_index :audit_logs, :created_at
    add_index :audit_logs, :checksum, unique: true
  end
end
