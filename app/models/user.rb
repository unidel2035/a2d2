class User < ApplicationRecord
  has_secure_password

  # Enums for ROB-007: Operator management
  enum role: {
    viewer: 0,
    operator: 1,
    technician: 2,
    admin: 3
  }

  # Associations
  has_many :documents, dependent: :destroy
  has_many :processes, dependent: :destroy
  has_many :dashboards, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :integrations, dependent: :destroy
  has_many :operated_tasks, class_name: "Task", foreign_key: :operator_id, dependent: :nullify
  has_many :maintenance_records, foreign_key: :technician_id, dependent: :nullify
  has_one_attached :certificate # For operator certificates

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :password, length: { minimum: 8 }, if: -> { new_record? || !password.nil? }
  validates :license_expiry, comparison: { greater_than: Date.current }, if: :license_number?

  # Scopes
  scope :active_operators, -> { where(role: [:operator, :technician, :admin]) }
  scope :license_expiring_soon, -> { where("license_expiry <= ?", 30.days.from_now).where("license_expiry >= ?", Date.current) }

  # Methods
  def full_name
    "#{first_name} #{last_name}".strip
  end

  def license_valid?
    license_number.present? && license_expiry.present? && license_expiry > Date.current
  end

  def license_expired?
    license_expiry.present? && license_expiry <= Date.current
  end

  def can_operate?
    (operator? || technician? || admin?) && license_valid?
  end

  def can_maintain?
    (technician? || admin?) && license_valid?
  end

  def can_admin?
    admin?
  end

  # Statistics
  def total_tasks_operated
    operated_tasks.where(status: :completed).count
  end

  def total_maintenance_performed
    maintenance_records.where(status: :completed).count
  end
end
