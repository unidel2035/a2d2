# frozen_string_literal: true

# Migration to add Devise fields to Users table
# AUTH-001: Multi-factor authentication fields
# AUTH-002: Session management fields
# AUTH-005: API token management
class AddDeviseToUsers < ActiveRecord::Migration[8.1]
  def change
    # Remove password_digest if it exists (we're switching to Devise)
    remove_column :users, :password_digest, :string, if_exists: true

    # Devise database_authenticatable
    add_column :users, :encrypted_password, :string, null: false, default: ""

    # Devise recoverable
    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_sent_at, :datetime

    # Devise rememberable (disabled for security, but keeping structure)
    add_column :users, :remember_created_at, :datetime

    # Devise trackable
    add_column :users, :sign_in_count, :integer, default: 0, null: false
    add_column :users, :current_sign_in_at, :datetime
    add_column :users, :last_sign_in_at, :datetime
    add_column :users, :current_sign_in_ip, :string
    add_column :users, :last_sign_in_ip, :string

    # Devise confirmable
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string

    # Devise lockable
    add_column :users, :failed_attempts, :integer, default: 0, null: false
    add_column :users, :unlock_token, :string
    add_column :users, :locked_at, :datetime

    # Two-factor authentication (AUTH-001: MFA)
    add_column :users, :otp_secret, :string
    add_column :users, :otp_required_for_login, :boolean, default: false, null: false
    add_column :users, :otp_backup_codes, :text

    # API Token Management (AUTH-005)
    add_column :users, :api_token, :string
    add_column :users, :api_token_created_at, :datetime

    # Session management (AUTH-006)
    add_column :users, :session_token, :string

    # Consent tracking (COMP-001: FZ-152 compliance)
    add_column :users, :data_processing_consent, :boolean, default: false, null: false
    add_column :users, :data_processing_consent_at, :datetime
    add_column :users, :privacy_policy_accepted_at, :datetime
    add_column :users, :terms_of_service_accepted_at, :datetime

    # Add indexes for performance and uniqueness
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token, unique: true
    add_index :users, :unlock_token, unique: true
    add_index :users, :api_token, unique: true
    add_index :users, :session_token, unique: true
  end
end
