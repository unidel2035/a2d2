class ScheduledReportJob < ApplicationJob
  queue_as :default

  # ANL-005: Scheduled reports
  def perform(report_id)
    report = Report.find(report_id)
    return unless report.active?

    report.generate!
  rescue StandardError => e
    Rails.logger.error "Scheduled report generation failed: #{e.message}"
    report.update!(status: :failed) if report
    raise
  end

  # Class method to enqueue all due reports
  def self.enqueue_due_reports
    Report.due.find_each do |report|
      perform_later(report.id)
    end
  end
end
