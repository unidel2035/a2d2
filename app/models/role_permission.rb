# frozen_string_literal: true

# Join table for roles and permissions
# AUTH-002: RBAC (Role-Based Access Control)
class RolePermission < ApplicationRecord
  belongs_to :role
  belongs_to :permission

  validates :role_id, uniqueness: { scope: :permission_id }
end
