# ROB-004: Лог уведомлений о техническом обслуживании
class NotificationLog < ApplicationRecord
  # Polymorphic association для связи с любым типом уведомлений
  belongs_to :notifiable, polymorphic: true

  # Validations
  validates :notification_type, presence: true
  validates :sent_at, presence: true

  # Scopes
  scope :recent, -> { order(sent_at: :desc) }
  scope :by_type, ->(type) { where(notification_type: type) }
  scope :for_maintenance, -> { where(notification_type: "maintenance_reminder") }
  scope :sent_today, -> { where("sent_at >= ?", Date.current.beginning_of_day) }
  scope :sent_this_week, -> { where("sent_at >= ?", 1.week.ago) }

  # Serialization для хранения сложных данных
  serialize :recipients, coder: JSON
  serialize :metadata, coder: JSON

  # Methods
  def self.log_maintenance_notification(maintenance_record, recipients, days_before)
    create!(
      notifiable: maintenance_record,
      notification_type: "maintenance_reminder",
      recipients: recipients,
      days_before: days_before,
      scheduled_date: maintenance_record.scheduled_date,
      sent_at: Time.current,
      metadata: {
        robot_id: maintenance_record.robot_id,
        robot_serial: maintenance_record.robot&.serial_number,
        technician_id: maintenance_record.technician_id,
        maintenance_type: maintenance_record.maintenance_type
      }
    )
  end

  def recipient_count
    recipients&.size || 0
  end

  def recipient_emails
    recipients&.map { |r| r["email"] }&.join(", ")
  end
end
