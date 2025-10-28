# frozen_string_literal: true

# Permission model for RBAC
# AUTH-002: RBAC (Role-Based Access Control)
class Permission < ApplicationRecord
  has_many :role_permissions, dependent: :destroy
  has_many :roles, through: :role_permissions

  validates :name, presence: true
  validates :resource, presence: true
  validates :action, presence: true
  validates :action, uniqueness: { scope: :resource }

  # Common actions
  ACTIONS = %w[create read update delete manage].freeze

  scope :for_resource, ->(resource) { where(resource: resource) }
  scope :for_action, ->(action) { where(action: action) }

  def full_name
    "#{resource}:#{action}"
  end
end
