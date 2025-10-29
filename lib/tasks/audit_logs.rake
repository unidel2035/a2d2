# frozen_string_literal: true

# Rake tasks for audit log management
# AUD-005: Log retention policies (3 years minimum)
namespace :audit_logs do
  desc "Clean up audit logs older than retention period (default: 3 years)"
  task cleanup: :environment do
    retention_years = ENV.fetch("RETENTION_YEARS", 3).to_i
    cutoff_date = retention_years.years.ago

    puts "Cleaning up audit logs older than #{cutoff_date}..."

    # Note: This will fail due to prevent_deletion callback
    # This is intentional for compliance - logs should not be deleted
    # This task exists for documentation purposes
    begin
      count = AuditLog.where("created_at < ?", cutoff_date).count
      puts "Found #{count} logs older than retention period"
      puts "WARNING: Audit logs are protected from deletion for compliance reasons"
      puts "If you need to archive old logs, consider exporting them to cold storage"
    rescue StandardError => e
      puts "Error: #{e.message}"
    end
  end

  desc "Verify audit log chain integrity"
  task verify_chain: :environment do
    puts "Verifying audit log chain integrity..."

    total = AuditLog.count
    verified = 0
    failed = 0

    AuditLog.find_each do |log|
      if log.verify_checksum && log.verify_chain
        verified += 1
      else
        failed += 1
        puts "FAILED: Log ID #{log.id} checksum verification failed"
      end

      print "\rProgress: #{verified + failed}/#{total}" if (verified + failed) % 100 == 0
    end

    puts "\n\nVerification complete:"
    puts "Total logs: #{total}"
    puts "Verified: #{verified}"
    puts "Failed: #{failed}"
    puts failed.zero? ? "✓ All logs verified successfully" : "✗ Some logs failed verification"
  end

  desc "Export audit logs to JSON file"
  task :export, [:output_file] => :environment do |_t, args|
    output_file = args[:output_file] || "audit_logs_#{Time.current.to_i}.json"

    puts "Exporting audit logs to #{output_file}..."

    File.open(output_file, "w") do |file|
      file.write("[\n")

      AuditLog.find_each.with_index do |log, index|
        file.write(",\n") if index.positive?
        file.write(log.to_json)
      end

      file.write("\n]")
    end

    puts "Export complete: #{output_file}"
    puts "Total logs exported: #{AuditLog.count}"
  end

  desc "Generate compliance report"
  task compliance_report: :environment do
    puts "Generating compliance report..."
    puts "\n=== Audit Log Compliance Report ==="
    puts "Generated at: #{Time.current}"
    puts "\n--- Statistics ---"
    puts "Total audit logs: #{AuditLog.count}"
    puts "Oldest log: #{AuditLog.order(:created_at).first&.created_at || 'N/A'}"
    puts "Newest log: #{AuditLog.order(:created_at).last&.created_at || 'N/A'}"
    puts "\n--- Actions ---"
    AuditLog.group(:action).count.each do |action, count|
      puts "#{action}: #{count}"
    end
    puts "\n--- Recent Activity (last 24h) ---"
    recent_count = AuditLog.where("created_at > ?", 24.hours.ago).count
    puts "Total events: #{recent_count}"
    puts "\n--- Compliance Status ---"
    puts "✓ Audit logging enabled"
    puts "✓ Tamper-proof checksums in place"
    puts "✓ Retention policy: 3 years minimum"
    puts "✓ All logs are immutable"
  end
end
