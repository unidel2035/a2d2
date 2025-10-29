require "test_helper"

class MaintenanceMailerTest < ActionMailer::TestCase
  setup do
    @robot = Robot.create!(
      serial_number: "TEST-ROBOT-001",
      manufacturer: "Test Manufacturer",
      model: "TM-2000",
      status: :active,
      total_operation_hours: 1500,
      location: "Warehouse A"
    )

    @technician = User.create!(
      email: "technician@test.com",
      name: "Ivan Technician",
      password: "SecurePassword123!",
      role: :technician,
      data_processing_consent: true
    )

    @operator = User.create!(
      email: "operator@test.com",
      name: "Sergey Operator",
      password: "SecurePassword123!",
      role: :operator,
      data_processing_consent: true
    )

    @maintenance_record = MaintenanceRecord.create!(
      robot: @robot,
      technician: @technician,
      scheduled_date: Date.current + 7.days,
      maintenance_type: :routine,
      status: :scheduled,
      description: "Плановое техническое обслуживание"
    )
  end

  test "upcoming_maintenance_technician email should be sent" do
    email = MaintenanceMailer.upcoming_maintenance_technician(@maintenance_record, 7)

    assert_emails 1 do
      email.deliver_now
    end
  end

  test "upcoming_maintenance_technician email should have correct recipient" do
    email = MaintenanceMailer.upcoming_maintenance_technician(@maintenance_record, 7)

    assert_equal [@technician.email], email.to
    assert_equal "from@example.com", email.from.first
  end

  test "upcoming_maintenance_technician email should have correct subject for 7 days" do
    email = MaintenanceMailer.upcoming_maintenance_technician(@maintenance_record, 7)

    assert_match "Напоминание: ТО робота #{@robot.serial_number} через 7 дней", email.subject
  end

  test "upcoming_maintenance_technician email should have correct subject for 1 day" do
    email = MaintenanceMailer.upcoming_maintenance_technician(@maintenance_record, 1)

    assert_match "Напоминание: ТО робота #{@robot.serial_number} через 1 день", email.subject
  end

  test "upcoming_maintenance_technician email body should contain robot details" do
    email = MaintenanceMailer.upcoming_maintenance_technician(@maintenance_record, 7)

    assert_match @robot.serial_number, email.body.encoded
    assert_match @robot.manufacturer, email.body.encoded
    assert_match @maintenance_record.scheduled_date.strftime("%d.%m.%Y"), email.body.encoded
  end

  test "upcoming_maintenance_technician email should contain technician name" do
    email = MaintenanceMailer.upcoming_maintenance_technician(@maintenance_record, 7)

    assert_match @technician.name, email.body.encoded
  end

  test "upcoming_maintenance_technician email should have both HTML and text parts" do
    email = MaintenanceMailer.upcoming_maintenance_technician(@maintenance_record, 7)

    assert_equal 2, email.parts.size
    assert_equal "text/plain", email.parts[0].content_type.split(";").first
    assert_equal "text/html", email.parts[1].content_type.split(";").first
  end

  test "upcoming_maintenance_operator email should be sent" do
    email = MaintenanceMailer.upcoming_maintenance_operator(@maintenance_record, @operator, 7)

    assert_emails 1 do
      email.deliver_now
    end
  end

  test "upcoming_maintenance_operator email should have correct recipient" do
    email = MaintenanceMailer.upcoming_maintenance_operator(@maintenance_record, @operator, 7)

    assert_equal [@operator.email], email.to
  end

  test "upcoming_maintenance_operator email should have correct subject" do
    email = MaintenanceMailer.upcoming_maintenance_operator(@maintenance_record, @operator, 7)

    assert_match "Уведомление: Плановое ТО робота #{@robot.serial_number} через 7 дней", email.subject
  end

  test "upcoming_maintenance_operator email body should contain robot details" do
    email = MaintenanceMailer.upcoming_maintenance_operator(@maintenance_record, @operator, 7)

    assert_match @robot.serial_number, email.body.encoded
    assert_match @maintenance_record.scheduled_date.strftime("%d.%m.%Y"), email.body.encoded
  end

  test "upcoming_maintenance_operator email should contain operator name" do
    email = MaintenanceMailer.upcoming_maintenance_operator(@maintenance_record, @operator, 7)

    assert_match @operator.name, email.body.encoded
  end

  test "upcoming_maintenance_operator email should contain technician info" do
    email = MaintenanceMailer.upcoming_maintenance_operator(@maintenance_record, @operator, 7)

    assert_match @technician.name, email.body.encoded
    assert_match @technician.email, email.body.encoded
  end

  test "upcoming_maintenance_operator email should contain warning message" do
    email = MaintenanceMailer.upcoming_maintenance_operator(@maintenance_record, @operator, 7)

    assert_match "недоступен для задач", email.body.encoded
  end

  test "urgent notification should be highlighted for 1 day warning" do
    email_tech = MaintenanceMailer.upcoming_maintenance_technician(@maintenance_record, 1)
    email_op = MaintenanceMailer.upcoming_maintenance_operator(@maintenance_record, @operator, 1)

    assert_match "завтра", email_tech.body.encoded
    assert_match "завтра", email_op.body.encoded
  end

  test "emails should contain A2D2 system reference" do
    email_tech = MaintenanceMailer.upcoming_maintenance_technician(@maintenance_record, 7)
    email_op = MaintenanceMailer.upcoming_maintenance_operator(@maintenance_record, @operator, 7)

    assert_match "A2D2", email_tech.body.encoded
    assert_match "A2D2", email_op.body.encoded
  end
end
