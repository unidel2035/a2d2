# frozen_string_literal: true

# Join table for users and roles
# AUTH-002: RBAC (Role-Based Access Control)
class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role

  validates :user_id, uniqueness: { scope: :role_id }
end
