# frozen_string_literal: true

# Base application policy for Pundit authorization
# AUTH-002: RBAC (Role-Based Access Control)
# Defines default authorization rules for all models
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user.present?
  end

  def show?
    user.present? && (user.admin? || owner?)
  end

  def create?
    user.present?
  end

  def new?
    create?
  end

  def update?
    user.present? && (user.admin? || owner?)
  end

  def edit?
    update?
  end

  def destroy?
    user.present? && (user.admin? || owner?)
  end

  # Check if user is the owner of the record
  def owner?
    record.respond_to?(:user_id) && record.user_id == user.id
  end

  # Scope for filtering records based on user permissions
  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if @user.admin?
        @scope.all
      elsif @user.present?
        @scope.where(user_id: @user.id)
      else
        @scope.none
      end
    end

    private

    attr_reader :user, :scope
  end
end
