# frozen_string_literal: true

# AuditLog model for security auditing
# AUD-001: Audit trail of all critical operations
# AUD-002: User activity logging
# AUD-003: Tamper-proof logs with checksums
class AuditLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :auditable, polymorphic: true, optional: true

  # Validations
  validates :action, presence: true
  validates :auditable_type, presence: true
  validates :checksum, presence: true, uniqueness: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }
  scope :for_action, ->(action) { where(action: action) }
  scope :for_auditable, ->(type, id) { where(auditable_type: type, auditable_id: id) }
  scope :successful, -> { where(status: "success") }
  scope :failed, -> { where(status: "failure") }

  # AUD-005: Retention policy - 3 years minimum
  scope :expired, -> { where("created_at < ?", 3.years.ago) }

  # Prevent modifications and deletions
  before_update :prevent_modification
  before_destroy :prevent_deletion

  # Generate checksum before creation (AUD-003)
  before_create :generate_checksum

  # Log action
  def self.log(action:, user: nil, auditable: nil, changes: nil, ip_address: nil, user_agent: nil, request_id: nil, metadata: nil, status: "success", error_message: nil)
    create!(
      action: action,
      user: user,
      auditable: auditable,
      changes: changes&.to_json,
      ip_address: ip_address,
      user_agent: user_agent,
      request_id: request_id,
      metadata: metadata&.to_json,
      status: status,
      error_message: error_message
    )
  rescue StandardError => e
    Rails.logger.error("Failed to create audit log: #{e.message}")
    # Don't fail the main operation if audit logging fails
    nil
  end

  # Verify checksum integrity
  def verify_checksum
    calculated_checksum = calculate_checksum
    checksum == calculated_checksum
  end

  # Verify chain integrity
  def verify_chain
    return true unless previous_checksum

    previous_log = AuditLog.find_by(checksum: previous_checksum)
    previous_log.present? && previous_log.verify_checksum
  end

  # Parse JSON fields
  def parsed_changes
    changes.present? ? JSON.parse(changes) : {}
  rescue JSON::ParserError
    {}
  end

  def parsed_metadata
    metadata.present? ? JSON.parse(metadata) : {}
  rescue JSON::ParserError
    {}
  end

  private

  # AUD-003: Generate tamper-proof checksum
  def generate_checksum
    # Get the previous log's checksum to chain logs together
    last_log = AuditLog.order(created_at: :desc).first
    self.previous_checksum = last_log&.checksum

    # Calculate checksum
    self.checksum = calculate_checksum
  end

  def calculate_checksum
    data = [
      user_id,
      action,
      auditable_type,
      auditable_id,
      changes,
      previous_checksum,
      created_at&.to_i || Time.current.to_i
    ].join("|")

    Digest::SHA256.hexdigest(data)
  end

  def prevent_modification
    raise ActiveRecord::RecordInvalid, "Audit logs cannot be modified"
  end

  def prevent_deletion
    raise ActiveRecord::RecordNotDestroyed, "Audit logs cannot be deleted"
  end
end
