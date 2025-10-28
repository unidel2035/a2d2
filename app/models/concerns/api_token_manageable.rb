# frozen_string_literal: true

# AUTH-005: API Token Management
# Provides API token generation and validation for User model
module ApiTokenManageable
  extend ActiveSupport::Concern

  included do
    before_create :generate_api_token
  end

  # Generate a new API token
  def generate_api_token
    self.api_token = SecureRandom.urlsafe_base64(32)
    self.api_token_created_at = Time.current
  end

  # Regenerate API token (for rotation)
  def regenerate_api_token!
    generate_api_token
    save!
  end

  # Check if API token needs rotation (older than 90 days)
  def api_token_expired?
    return true unless api_token_created_at

    api_token_created_at < 90.days.ago
  end

  # Validate API token
  def valid_api_token?(token)
    return false if api_token_expired?

    ActiveSupport::SecurityUtils.secure_compare(api_token.to_s, token.to_s)
  end

  # Revoke API token
  def revoke_api_token!
    self.api_token = nil
    self.api_token_created_at = nil
    save!
  end

  class_methods do
    # Find user by API token
    def find_by_api_token(token)
      return nil if token.blank?

      user = find_by(api_token: token)
      return nil if user.nil? || user.api_token_expired?

      user
    end
  end
end
