# frozen_string_literal: true

# Policy for AuditLog access
# AUD-001: Audit logs are only accessible by admins
class AuditLogPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin?
  end

  def create?
    false # Audit logs are created automatically
  end

  def update?
    false # Audit logs are immutable
  end

  def destroy?
    false # Audit logs cannot be deleted (for compliance)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if @user.admin?
        @scope.all
      else
        @scope.none
      end
    end
  end
end
