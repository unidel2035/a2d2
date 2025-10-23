class Spreadsheet < ApplicationRecord
  # Associations
  has_many :sheets, dependent: :destroy
  has_many :collaborators, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { minimum: 1, maximum: 255 }

  # Callbacks
  before_create :generate_share_token

  # Scopes
  scope :public_spreadsheets, -> { where(public: true) }
  scope :owned_by, ->(user_id) { where(owner_id: user_id) }

  # Instance methods
  def owner
    # TODO: Replace with User model once authentication is implemented
    User.find_by(id: owner_id) if owner_id
  end

  def shared_with?(user_id)
    collaborators.exists?(user_id: user_id)
  end

  def accessible_by?(user_id)
    return true if public
    return true if owner_id == user_id
    shared_with?(user_id)
  end

  def permission_for(user_id)
    return 'admin' if owner_id == user_id
    collaborators.find_by(user_id: user_id)&.permission || 'none'
  end

  private

  def generate_share_token
    self.share_token = SecureRandom.urlsafe_base64(32)
  end
end
