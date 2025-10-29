require "test_helper"

class NotificationLogTest < ActiveSupport::TestCase
  setup do
    @robot = Robot.create!(
      serial_number: "TEST-ROBOT-001",
      manufacturer: "Test Manufacturer",
      status: :active
    )

    @technician = User.create!(
      email: "technician@test.com",
      name: "Test Technician",
      password: "SecurePassword123!",
      role: :technician,
      data_processing_consent: true
    )

    @maintenance_record = MaintenanceRecord.create!(
      robot: @robot,
      technician: @technician,
      scheduled_date: Date.current + 7.days,
      maintenance_type: :routine,
      status: :scheduled
    )
  end

  test "should create notification log" do
    log = NotificationLog.create!(
      notifiable: @maintenance_record,
      notification_type: "maintenance_reminder",
      recipients: [ { type: "technician", email: @technician.email } ],
      days_before: 7,
      scheduled_date: @maintenance_record.scheduled_date,
      sent_at: Time.current
    )

    assert log.persisted?
    assert_equal @maintenance_record, log.notifiable
  end

  test "should require notification_type" do
    log = NotificationLog.new(
      notifiable: @maintenance_record,
      sent_at: Time.current
    )

    assert_not log.valid?
    assert_includes log.errors[:notification_type], "can't be blank"
  end

  test "should require sent_at" do
    log = NotificationLog.new(
      notifiable: @maintenance_record,
      notification_type: "maintenance_reminder"
    )

    assert_not log.valid?
    assert_includes log.errors[:sent_at], "can't be blank"
  end

  test "should support polymorphic association" do
    log = NotificationLog.create!(
      notifiable: @maintenance_record,
      notification_type: "maintenance_reminder",
      sent_at: Time.current
    )

    assert_equal "MaintenanceRecord", log.notifiable_type
    assert_equal @maintenance_record.id, log.notifiable_id
  end

  test "recent scope should order by sent_at desc" do
    log1 = NotificationLog.create!(
      notifiable: @maintenance_record,
      notification_type: "maintenance_reminder",
      sent_at: 2.days.ago
    )

    log2 = NotificationLog.create!(
      notifiable: @maintenance_record,
      notification_type: "maintenance_reminder",
      sent_at: 1.day.ago
    )

    logs = NotificationLog.recent

    assert_equal log2.id, logs.first.id
    assert_equal log1.id, logs.last.id
  end

  test "by_type scope should filter by notification_type" do
    log1 = NotificationLog.create!(
      notifiable: @maintenance_record,
      notification_type: "maintenance_reminder",
      sent_at: Time.current
    )

    log2 = NotificationLog.create!(
      notifiable: @maintenance_record,
      notification_type: "deadline_alert",
      sent_at: Time.current
    )

    maintenance_logs = NotificationLog.by_type("maintenance_reminder")

    assert_equal 1, maintenance_logs.count
    assert_equal log1.id, maintenance_logs.first.id
  end

  test "for_maintenance scope should filter maintenance reminders" do
    log = NotificationLog.create!(
      notifiable: @maintenance_record,
      notification_type: "maintenance_reminder",
      sent_at: Time.current
    )

    maintenance_logs = NotificationLog.for_maintenance

    assert_equal 1, maintenance_logs.count
    assert_equal log.id, maintenance_logs.first.id
  end

  test "sent_today scope should filter today's notifications" do
    log_today = NotificationLog.create!(
      notifiable: @maintenance_record,
      notification_type: "maintenance_reminder",
      sent_at: Time.current
    )

    log_yesterday = NotificationLog.create!(
      notifiable: @maintenance_record,
      notification_type: "maintenance_reminder",
      sent_at: 1.day.ago
    )

    today_logs = NotificationLog.sent_today

    assert_equal 1, today_logs.count
    assert_equal log_today.id, today_logs.first.id
  end

  test "sent_this_week scope should filter this week's notifications" do
    log_this_week = NotificationLog.create!(
      notifiable: @maintenance_record,
      notification_type: "maintenance_reminder",
      sent_at: 2.days.ago
    )

    log_old = NotificationLog.create!(
      notifiable: @maintenance_record,
      notification_type: "maintenance_reminder",
      sent_at: 10.days.ago
    )

    week_logs = NotificationLog.sent_this_week

    assert_equal 1, week_logs.count
    assert_equal log_this_week.id, week_logs.first.id
  end

  test "should serialize recipients as JSON" do
    recipients = [
      { type: "technician", email: "tech@test.com" },
      { type: "operator", email: "op@test.com" }
    ]

    log = NotificationLog.create!(
      notifiable: @maintenance_record,
      notification_type: "maintenance_reminder",
      recipients: recipients,
      sent_at: Time.current
    )

    assert_equal 2, log.recipients.size
    assert_equal "tech@test.com", log.recipients[0]["email"]
  end

  test "should serialize metadata as JSON" do
    metadata = {
      robot_id: @robot.id,
      robot_serial: @robot.serial_number,
      technician_id: @technician.id
    }

    log = NotificationLog.create!(
      notifiable: @maintenance_record,
      notification_type: "maintenance_reminder",
      metadata: metadata,
      sent_at: Time.current
    )

    assert_equal @robot.id, log.metadata["robot_id"]
    assert_equal @robot.serial_number, log.metadata["robot_serial"]
  end

  test "recipient_count should return correct count" do
    recipients = [
      { type: "technician", email: "tech@test.com" },
      { type: "operator", email: "op1@test.com" },
      { type: "operator", email: "op2@test.com" }
    ]

    log = NotificationLog.create!(
      notifiable: @maintenance_record,
      notification_type: "maintenance_reminder",
      recipients: recipients,
      sent_at: Time.current
    )

    assert_equal 3, log.recipient_count
  end

  test "recipient_count should return 0 for nil recipients" do
    log = NotificationLog.create!(
      notifiable: @maintenance_record,
      notification_type: "maintenance_reminder",
      sent_at: Time.current
    )

    assert_equal 0, log.recipient_count
  end

  test "recipient_emails should return comma-separated emails" do
    recipients = [
      { "type" => "technician", "email" => "tech@test.com" },
      { "type" => "operator", "email" => "op@test.com" }
    ]

    log = NotificationLog.create!(
      notifiable: @maintenance_record,
      notification_type: "maintenance_reminder",
      recipients: recipients,
      sent_at: Time.current
    )

    assert_equal "tech@test.com, op@test.com", log.recipient_emails
  end

  test "log_maintenance_notification class method should create log" do
    recipients = [
      { type: "technician", email: @technician.email }
    ]

    assert_difference "NotificationLog.count", 1 do
      NotificationLog.log_maintenance_notification(@maintenance_record, recipients, 7)
    end

    log = NotificationLog.last
    assert_equal "maintenance_reminder", log.notification_type
    assert_equal 7, log.days_before
    assert_equal @maintenance_record, log.notifiable
  end
end
