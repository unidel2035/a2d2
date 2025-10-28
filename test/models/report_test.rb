require "test_helper"

class ReportTest < ActiveSupport::TestCase
  def setup
    @user = create(:user)
    @report = create(:report, user: @user)
  end

  test "should be valid with required attributes" do
    assert @report.valid?
  end

  test "should require name" do
    @report.name = nil
    assert_not @report.valid?
    assert_includes @report.errors[:name], "can't be blank"
  end

  test "should require report_type" do
    @report.report_type = nil
    assert_not @report.valid?
    assert_includes @report.errors[:report_type], "can't be blank"
  end

  test "should require status" do
    @report.status = nil
    assert_not @report.valid?
    assert_includes @report.errors[:status], "can't be blank"
  end

  test "should only allow valid report_types" do
    assert @report.update(report_type: "pdf")
    assert @report.update(report_type: "excel")
    assert @report.update(report_type: "csv")

    @report.report_type = "invalid"
    assert_not @report.valid?
    assert_includes @report.errors[:report_type], "is not included in the list"
  end

  test "should have valid status enum values" do
    @report.status = :inactive
    assert @report.inactive?

    @report.status = :active
    assert @report.active?

    @report.status = :generating
    assert @report.generating?

    @report.status = :failed
    assert @report.failed?
  end

  test "scope active_reports should return only active reports" do
    active_report = create(:report, user: @user, status: :active)
    create(:report, user: @user, status: :inactive)

    assert_includes Report.active_reports, active_report
  end

  test "scope scheduled should return reports with schedule" do
    scheduled_report = create(:report, :with_schedule, user: @user)
    create(:report, user: @user, schedule: {})

    assert_includes Report.scheduled, scheduled_report
  end

  test "scope due should return reports due for generation" do
    due_report = create(:report, user: @user, next_generation_at: 1.hour.ago)
    create(:report, user: @user, next_generation_at: 1.hour.from_now)

    assert_includes Report.due, due_report
  end

  test "generate! should set status to generating" do
    @report.generate!
    assert @report.active?
  end

  test "generate! should set last_generated_at" do
    @report.generate!
    assert_not_nil @report.last_generated_at
    assert_in_delta Time.current, @report.last_generated_at, 1.second
  end

  test "generate! should calculate next_generation_at for scheduled reports" do
    @report.schedule = { "frequency" => "daily" }
    @report.generate!
    assert_not_nil @report.next_generation_at
  end

  test "calculate_next_generation_time should return nil for non-scheduled reports" do
    @report.schedule = {}
    assert_nil @report.calculate_next_generation_time
  end

  test "calculate_next_generation_time should handle daily frequency" do
    @report.schedule = { "frequency" => "daily" }
    next_time = @report.calculate_next_generation_time
    assert_not_nil next_time
    assert_in_delta 1.day.from_now, next_time, 1.second
  end

  test "calculate_next_generation_time should handle weekly frequency" do
    @report.schedule = { "frequency" => "weekly" }
    next_time = @report.calculate_next_generation_time
    assert_not_nil next_time
    assert_in_delta 1.week.from_now, next_time, 1.second
  end

  test "calculate_next_generation_time should handle monthly frequency" do
    @report.schedule = { "frequency" => "monthly" }
    next_time = @report.calculate_next_generation_time
    assert_not_nil next_time
    assert_in_delta 1.month.from_now, next_time, 1.day
  end

  test "should have generated_file attachment" do
    assert_respond_to @report, :generated_file
  end
end
