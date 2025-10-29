# frozen_string_literal: true

# Auditable concern for automatic CRUD operation logging
# AUD-001: Audit trail of all critical operations
# Include this concern in models that need audit logging
module Auditable
  extend ActiveSupport::Concern

  included do
    after_create :log_create
    after_update :log_update
    after_destroy :log_destroy
  end

  private

  def log_create
    log_audit_event("create", changes: saved_changes)
  end

  def log_update
    log_audit_event("update", changes: saved_changes)
  end

  def log_destroy
    log_audit_event("destroy")
  end

  def log_audit_event(action, changes: nil)
    # Get current user from RequestStore or thread
    current_user = Current.user rescue nil

    # Get request details if available
    request = Current.request rescue nil
    ip_address = request&.remote_ip
    user_agent = request&.user_agent
    request_id = request&.request_id

    AuditLog.log(
      action: action,
      user: current_user,
      auditable: self,
      changes: changes,
      ip_address: ip_address,
      user_agent: user_agent,
      request_id: request_id
    )
  end

  class_methods do
    # Enable auditing for specific actions only
    def audit_only(*actions)
      actions.each do |action|
        case action
        when :create
          after_create :log_create
        when :update
          after_update :log_update
        when :destroy
          after_destroy :log_destroy
        end
      end
    end

    # Disable auditing for specific actions
    def skip_audit(*actions)
      actions.each do |action|
        case action
        when :create
          skip_callback :create, :after, :log_create
        when :update
          skip_callback :update, :after, :log_update
        when :destroy
          skip_callback :destroy, :after, :log_destroy
        end
      end
    end
  end
end
