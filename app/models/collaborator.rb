class Collaborator < ApplicationRecord
  # Associations
  belongs_to :spreadsheet

  # Validations
  validates :permission, presence: true, inclusion: { in: %w[view edit admin] }
  validate :user_or_email_present
  validates :user_id, uniqueness: { scope: :spreadsheet_id }, if: -> { user_id.present? }
  validates :email, uniqueness: { scope: :spreadsheet_id }, if: -> { email.present? }

  # Scopes
  scope :with_permission, ->(permission) { where(permission: permission) }
  scope :can_edit, -> { where(permission: %w[edit admin]) }
  scope :can_admin, -> { where(permission: 'admin') }

  # Instance methods
  def user
    # TODO: Replace with User model once authentication is implemented
    User.find_by(id: user_id) if user_id
  end

  def can_view?
    %w[view edit admin].include?(permission)
  end

  def can_edit?
    %w[edit admin].include?(permission)
  end

  def can_admin?
    permission == 'admin'
  end

  private

  def user_or_email_present
    if user_id.blank? && email.blank?
      errors.add(:base, 'Either user_id or email must be present')
    end
  end
end
