# frozen_string_literal: true

# Role model for RBAC
# AUTH-002: RBAC (Role-Based Access Control)
class Role < ApplicationRecord
  has_many :role_permissions, dependent: :destroy
  has_many :permissions, through: :role_permissions
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles

  validates :name, presence: true, uniqueness: true

  # Check if role has a specific permission
  def has_permission?(resource, action)
    permissions.exists?(resource: resource, action: action)
  end

  # Add permission to role
  def add_permission(permission)
    permissions << permission unless permissions.include?(permission)
  end

  # Remove permission from role
  def remove_permission(permission)
    permissions.delete(permission)
  end
end
