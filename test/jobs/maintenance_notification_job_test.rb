require "test_helper"

class MaintenanceNotificationJobTest < ActiveJob::TestCase
  setup do
    @robot = Robot.create!(
      serial_number: "TEST-ROBOT-001",
      manufacturer: "Test Manufacturer",
      status: :active,
      total_operation_hours: 1000
    )

    @technician = User.create!(
      email: "technician@test.com",
      name: "Test Technician",
      password: "SecurePassword123!",
      role: :technician,
      data_processing_consent: true
    )

    @operator = User.create!(
      email: "operator@test.com",
      name: "Test Operator",
      password: "SecurePassword123!",
      role: :operator,
      data_processing_consent: true
    )

    # Создаем задачу для робота, чтобы связать оператора
    @robot_task = RobotTask.create!(
      robot: @robot,
      operator: @operator,
      task_type: "inspection",
      status: :planned,
      planned_start: Date.current,
      planned_end: Date.current + 1.day
    )
  end

  test "job should be enqueued" do
    assert_enqueued_with(job: MaintenanceNotificationJob) do
      MaintenanceNotificationJob.perform_later
    end
  end

  test "job should use correct queue" do
    assert_equal "default", MaintenanceNotificationJob.new.queue_name
  end

  test "job should send notifications for maintenance scheduled in 7 days" do
    maintenance = MaintenanceRecord.create!(
      robot: @robot,
      technician: @technician,
      scheduled_date: Date.current + 7.days,
      maintenance_type: :routine,
      status: :scheduled
    )

    assert_emails 2 do # 1 для техника + 1 для оператора
      MaintenanceNotificationJob.perform_now
    end
  end

  test "job should send notifications for maintenance scheduled in 3 days" do
    maintenance = MaintenanceRecord.create!(
      robot: @robot,
      technician: @technician,
      scheduled_date: Date.current + 3.days,
      maintenance_type: :routine,
      status: :scheduled
    )

    assert_emails 2 do
      MaintenanceNotificationJob.perform_now
    end
  end

  test "job should send notifications for maintenance scheduled in 1 day" do
    maintenance = MaintenanceRecord.create!(
      robot: @robot,
      technician: @technician,
      scheduled_date: Date.current + 1.day,
      maintenance_type: :routine,
      status: :scheduled
    )

    assert_emails 2 do
      MaintenanceNotificationJob.perform_now
    end
  end

  test "job should not send notifications for maintenance scheduled in 5 days" do
    maintenance = MaintenanceRecord.create!(
      robot: @robot,
      technician: @technician,
      scheduled_date: Date.current + 5.days,
      maintenance_type: :routine,
      status: :scheduled
    )

    assert_no_emails do
      MaintenanceNotificationJob.perform_now
    end
  end

  test "job should not send notifications for completed maintenance" do
    maintenance = MaintenanceRecord.create!(
      robot: @robot,
      technician: @technician,
      scheduled_date: Date.current + 7.days,
      maintenance_type: :routine,
      status: :completed
    )

    assert_no_emails do
      MaintenanceNotificationJob.perform_now
    end
  end

  test "job should create notification logs" do
    maintenance = MaintenanceRecord.create!(
      robot: @robot,
      technician: @technician,
      scheduled_date: Date.current + 7.days,
      maintenance_type: :routine,
      status: :scheduled
    )

    assert_difference "NotificationLog.count", 1 do
      MaintenanceNotificationJob.perform_now
    end

    log = NotificationLog.last
    assert_equal "maintenance_reminder", log.notification_type
    assert_equal maintenance, log.notifiable
    assert_equal 7, log.days_before
    assert_equal 2, log.recipient_count # технник + оператор
  end

  test "job should handle maintenance without technician" do
    maintenance = MaintenanceRecord.create!(
      robot: @robot,
      technician: nil,
      scheduled_date: Date.current + 7.days,
      maintenance_type: :routine,
      status: :scheduled
    )

    # Должно отправиться только оператору
    assert_emails 1 do
      MaintenanceNotificationJob.perform_now
    end
  end

  test "job should return correct statistics" do
    # Создаем несколько записей ТО
    3.times do |i|
      MaintenanceRecord.create!(
        robot: @robot,
        technician: @technician,
        scheduled_date: Date.current + 7.days,
        maintenance_type: :routine,
        status: :scheduled
      )
    end

    result = MaintenanceNotificationJob.perform_now

    assert_equal 3, result[:notifications_sent]
    assert_equal 0, result[:errors]
    assert_not_nil result[:checked_at]
  end

  test "job should handle errors gracefully" do
    maintenance = MaintenanceRecord.create!(
      robot: @robot,
      technician: @technician,
      scheduled_date: Date.current + 7.days,
      maintenance_type: :routine,
      status: :scheduled
    )

    # Моделируем ошибку отправки
    MaintenanceMailer.stub :upcoming_maintenance_technician, ->(*args) { raise StandardError, "Email error" } do
      assert_nothing_raised do
        result = MaintenanceNotificationJob.perform_now
        assert_equal 1, result[:errors]
      end
    end
  end
end
