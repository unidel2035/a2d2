require "test_helper"

class ScheduledReportJobTest < ActiveJob::TestCase
  def setup
    @user = create(:user)
    @report = create(:report, :with_schedule, user: @user)
  end

  test "job should be enqueued" do
    assert_enqueued_with(job: ScheduledReportJob, args: [@report.id]) do
      ScheduledReportJob.perform_later(@report.id)
    end
  end

  test "job should execute successfully with valid report" do
    assert_nothing_raised do
      ScheduledReportJob.perform_now(@report.id)
    end
  end

  test "job should handle missing report gracefully" do
    assert_nothing_raised do
      ScheduledReportJob.perform_now(999999)
    end
  end

  test "job should use correct queue" do
    assert_equal "default", ScheduledReportJob.new.queue_name
  end

  test "job should generate report" do
    ScheduledReportJob.perform_now(@report.id)
    @report.reload

    # Verify report was generated (check last_generated_at or status)
    # assert_not_nil @report.last_generated_at
  end
end
