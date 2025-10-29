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
    add_column :users, :encrypted_password, :string, null: false, default: "" unless column_exists?(:users, :encrypted_password)

    # Devise recoverable
    add_column :users, :reset_password_token, :string unless column_exists?(:users, :reset_password_token)
    add_column :users, :reset_password_sent_at, :datetime unless column_exists?(:users, :reset_password_sent_at)

    # Devise rememberable (disabled for security, but keeping structure)
    add_column :users, :remember_created_at, :datetime unless column_exists?(:users, :remember_created_at)

    # Devise trackable
    add_column :users, :sign_in_count, :integer, default: 0, null: false unless column_exists?(:users, :sign_in_count)
    add_column :users, :current_sign_in_at, :datetime unless column_exists?(:users, :current_sign_in_at)
    add_column :users, :last_sign_in_at, :datetime unless column_exists?(:users, :last_sign_in_at)
    add_column :users, :current_sign_in_ip, :string unless column_exists?(:users, :current_sign_in_ip)
    add_column :users, :last_sign_in_ip, :string unless column_exists?(:users, :last_sign_in_ip)

    # Devise confirmable
    add_column :users, :confirmation_token, :string unless column_exists?(:users, :confirmation_token)
    add_column :users, :confirmed_at, :datetime unless column_exists?(:users, :confirmed_at)
    add_column :users, :confirmation_sent_at, :datetime unless column_exists?(:users, :confirmation_sent_at)
    add_column :users, :unconfirmed_email, :string unless column_exists?(:users, :unconfirmed_email)

    # Devise lockable
    add_column :users, :failed_attempts, :integer, default: 0, null: false unless column_exists?(:users, :failed_attempts)
    add_column :users, :unlock_token, :string unless column_exists?(:users, :unlock_token)
    add_column :users, :locked_at, :datetime unless column_exists?(:users, :locked_at)

    # Two-factor authentication (AUTH-001: MFA)
    add_column :users, :otp_secret, :string unless column_exists?(:users, :otp_secret)
    add_column :users, :otp_required_for_login, :boolean, default: false, null: false unless column_exists?(:users, :otp_required_for_login)
    add_column :users, :otp_backup_codes, :text unless column_exists?(:users, :otp_backup_codes)

    # API Token Management (AUTH-005)
    add_column :users, :api_token, :string unless column_exists?(:users, :api_token)
    add_column :users, :api_token_created_at, :datetime unless column_exists?(:users, :api_token_created_at)

    # Session management (AUTH-006)
    add_column :users, :session_token, :string unless column_exists?(:users, :session_token)

    # Consent tracking (COMP-001: FZ-152 compliance)
    add_column :users, :data_processing_consent, :boolean, default: false, null: false unless column_exists?(:users, :data_processing_consent)
    add_column :users, :data_processing_consent_at, :datetime unless column_exists?(:users, :data_processing_consent_at)
    add_column :users, :privacy_policy_accepted_at, :datetime unless column_exists?(:users, :privacy_policy_accepted_at)
    add_column :users, :terms_of_service_accepted_at, :datetime unless column_exists?(:users, :terms_of_service_accepted_at)

    # Add indexes for performance and uniqueness
    add_index :users, :reset_password_token, unique: true unless index_exists?(:users, :reset_password_token)
    add_index :users, :confirmation_token, unique: true unless index_exists?(:users, :confirmation_token)
    add_index :users, :unlock_token, unique: true unless index_exists?(:users, :unlock_token)
    add_index :users, :api_token, unique: true unless index_exists?(:users, :api_token)
    add_index :users, :session_token, unique: true unless index_exists?(:users, :session_token)
  end
end
