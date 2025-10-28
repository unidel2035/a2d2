class User < ApplicationRecord
  # AUTH-001: Devise modules for authentication
  # :database_authenticatable - password authentication
  # :recoverable - password reset
  # :trackable - track sign in count, timestamps and IP
  # :validatable - email and password validation
  # :confirmable - email confirmation
  # :lockable - lock account after failed attempts
  # :timeoutable - session timeout (30 minutes)
  # :two_factor_authenticatable - MFA support
  devise :database_authenticatable, :registerable,
         :recoverable, :trackable, :validatable,
         :confirmable, :lockable, :timeoutable,
         :two_factor_authenticatable,
         otp_secret_encryption_key: Rails.application.credentials.otp_secret_key || ENV["OTP_SECRET_KEY"]

  # Include API token management (AUTH-005)
  include ApiTokenManageable

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

  # AUTH-002: RBAC associations
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

  # Validations
  validates :name, presence: true
  validates :license_expiry, comparison: { greater_than: Date.current }, if: :license_number?
  validates :password, password_complexity: true, if: -> { new_record? || !password.nil? }
  validates :data_processing_consent, acceptance: true, on: :create # COMP-001: FZ-152 compliance

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

  # AUTH-002: RBAC permission checking
  def has_role?(role_name)
    roles.exists?(name: role_name)
  end

  def has_permission?(resource, action)
    return true if admin? # Admins have all permissions

    roles.any? { |role| role.has_permission?(resource, action) }
  end

  def add_role(role)
    roles << role unless roles.include?(role)
  end

  def remove_role(role)
    roles.delete(role)
  end

  # Statistics
  def total_tasks_operated
    operated_tasks.where(status: :completed).count
  end

  def total_maintenance_performed
    maintenance_records.where(status: :completed).count
  end

  # AUTH-001: MFA methods
  def enable_two_factor!
    self.otp_required_for_login = true
    self.otp_secret = User.generate_otp_secret
    generate_otp_backup_codes!
    save!
  end

  def disable_two_factor!
    self.otp_required_for_login = false
    self.otp_secret = nil
    self.otp_backup_codes = nil
    save!
  end

  def generate_otp_backup_codes!
    codes = 10.times.map { SecureRandom.hex(4) }
    self.otp_backup_codes = codes.join("\n")
    codes
  end

  def invalidate_otp_backup_code!(code)
    return false unless otp_backup_codes

    codes = otp_backup_codes.split("\n")
    return false unless codes.delete(code)

    self.otp_backup_codes = codes.join("\n")
    save!
  end

  # COMP-001: Data processing consent methods for FZ-152
  def accept_data_processing_consent!
    update(
      data_processing_consent: true,
      data_processing_consent_at: Time.current
    )
  end

  def accept_privacy_policy!
    update(privacy_policy_accepted_at: Time.current)
  end

  def accept_terms_of_service!
    update(terms_of_service_accepted_at: Time.current)
  end

  def consents_valid?
    data_processing_consent? &&
      privacy_policy_accepted_at.present? &&
      terms_of_service_accepted_at.present?
  end
end
