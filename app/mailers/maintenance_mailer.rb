# ROB-004: Mailer для уведомлений о техническом обслуживании
class MaintenanceMailer < ApplicationMailer
  # Уведомление техника о предстоящем ТО
  def upcoming_maintenance_technician(maintenance_record, days_before)
    @maintenance_record = maintenance_record
    @robot = maintenance_record.robot
    @days_before = days_before
    @technician = maintenance_record.technician

    render MaintenanceMailer::UpcomingMaintenanceTechnicianView.new(
      maintenance: @maintenance_record,
      technician: @technician
    )

    mail(
      to: @technician.email,
      subject: "Напоминание: ТО робота #{@robot.serial_number} через #{@days_before} #{days_word(@days_before)}"
    )
  end

  # Уведомление оператора о предстоящем ТО
  def upcoming_maintenance_operator(maintenance_record, operator, days_before)
    @maintenance_record = maintenance_record
    @robot = maintenance_record.robot
    @days_before = days_before
    @operator = operator
    @technician = maintenance_record.technician

    render MaintenanceMailer::UpcomingMaintenanceOperatorView.new(
      maintenance: @maintenance_record,
      operator: @operator
    )

    mail(
      to: @operator.email,
      subject: "Уведомление: Плановое ТО робота #{@robot.serial_number} через #{@days_before} #{days_word(@days_before)}"
    )
  end

  private

  def days_word(days)
    case days
    when 1
      "день"
    when 2, 3, 4
      "дня"
    else
      "дней"
    end
  end
end
