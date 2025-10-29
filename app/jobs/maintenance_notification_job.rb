# ROB-004: Уведомления о предстоящем техническом обслуживании
# SPECIFICATION.md строка 58: Уведомления за 7 дней до планового ТО
class MaintenanceNotificationJob < ApplicationJob
  queue_as :default

  # Диапазоны уведомлений (в днях до ТО)
  NOTIFICATION_INTERVALS = [ 7, 3, 1 ].freeze

  def perform
    Rails.logger.info "Starting maintenance notification check at #{Time.current}"

    notification_count = 0
    error_count = 0

    NOTIFICATION_INTERVALS.each do |days_before|
      target_date = Date.current + days_before.days

      # Найти запланированные ТО на целевую дату
      upcoming_maintenance = MaintenanceRecord
        .where(status: :scheduled)
        .where(scheduled_date: target_date)
        .includes(:robot, :technician)

      Rails.logger.info "Found #{upcoming_maintenance.count} maintenance records scheduled for #{target_date} (#{days_before} days from now)"

      upcoming_maintenance.each do |record|
        begin
          send_notifications(record, days_before)
          log_notification(record, days_before)
          notification_count += 1
        rescue StandardError => e
          Rails.logger.error "Failed to send notification for MaintenanceRecord ##{record.id}: #{e.message}"
          error_count += 1
        end
      end
    end

    Rails.logger.info "Maintenance notification check completed: #{notification_count} notifications sent, #{error_count} errors"

    {
      notifications_sent: notification_count,
      errors: error_count,
      checked_at: Time.current
    }
  end

  private

  def send_notifications(record, days_before)
    # Отправить уведомление технику
    if record.technician.present?
      MaintenanceMailer.upcoming_maintenance_technician(record, days_before).deliver_later
      Rails.logger.info "Sent technician notification for MaintenanceRecord ##{record.id} to #{record.technician.email}"
    end

    # Отправить уведомление оператору робота (если есть активные задачи)
    if record.robot.present?
      # Найти операторов, работающих с этим роботом
      active_operators = find_robot_operators(record.robot)

      active_operators.each do |operator|
        MaintenanceMailer.upcoming_maintenance_operator(record, operator, days_before).deliver_later
        Rails.logger.info "Sent operator notification for MaintenanceRecord ##{record.id} to #{operator.email}"
      end
    end
  end

  def find_robot_operators(robot)
    # Найти операторов с активными задачами на этом роботе
    operators = User.joins(:operated_tasks)
      .where(robot_tasks: { robot_id: robot.id, status: [ :planned, :in_progress ] })
      .distinct

    # Если нет активных операторов, найти последних операторов
    if operators.empty?
      operators = User.joins(:operated_tasks)
        .where(robot_tasks: { robot_id: robot.id })
        .order("robot_tasks.updated_at DESC")
        .limit(1)
    end

    operators
  end

  def log_notification(record, days_before)
    # Создать запись в логе уведомлений
    NotificationLog.create!(
      notifiable: record,
      notification_type: "maintenance_reminder",
      recipients: build_recipients_list(record),
      days_before: days_before,
      scheduled_date: record.scheduled_date,
      sent_at: Time.current,
      metadata: {
        robot_id: record.robot_id,
        robot_serial: record.robot&.serial_number,
        technician_id: record.technician_id,
        maintenance_type: record.maintenance_type
      }
    )
  end

  def build_recipients_list(record)
    recipients = []

    recipients << {
      type: "technician",
      user_id: record.technician_id,
      email: record.technician.email
    } if record.technician.present?

    find_robot_operators(record.robot).each do |operator|
      recipients << {
        type: "operator",
        user_id: operator.id,
        email: operator.email
      }
    end

    recipients
  end
end
