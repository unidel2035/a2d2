# frozen_string_literal: true

require "test_helper"

class AuditLogTest < ActiveSupport::TestCase
  # AUD-001: Audit logging tests
  test "should create audit log" do
    user = User.create!(
      email: "test@example.com",
      name: "Test User",
      password: "Strong@Pass123",
      data_processing_consent: true
    )

    log = AuditLog.log(
      action: "login",
      user: user,
      ip_address: "127.0.0.1",
      status: "success"
    )

    assert log.present?
    assert_equal "login", log.action
    assert_equal user.id, log.user_id
  end

  # AUD-003: Tamper-proof checksum tests
  test "should generate checksum on create" do
    user = User.create!(
      email: "test@example.com",
      name: "Test User",
      password: "Strong@Pass123",
      data_processing_consent: true
    )

    log = AuditLog.log(
      action: "test",
      user: user,
      status: "success"
    )

    assert log.checksum.present?
    assert_equal 64, log.checksum.length # SHA256 hex length
  end

  test "should verify checksum integrity" do
    user = User.create!(
      email: "test@example.com",
      name: "Test User",
      password: "Strong@Pass123",
      data_processing_consent: true
    )

    log = AuditLog.log(
      action: "test",
      user: user,
      status: "success"
    )

    assert log.verify_checksum
  end

  test "should prevent modification of audit logs" do
    user = User.create!(
      email: "test@example.com",
      name: "Test User",
      password: "Strong@Pass123",
      data_processing_consent: true
    )

    log = AuditLog.log(
      action: "test",
      user: user,
      status: "success"
    )

    assert_raises(ActiveRecord::RecordInvalid) do
      log.update!(action: "modified")
    end
  end

  test "should prevent deletion of audit logs" do
    user = User.create!(
      email: "test@example.com",
      name: "Test User",
      password: "Strong@Pass123",
      data_processing_consent: true
    )

    log = AuditLog.log(
      action: "test",
      user: user,
      status: "success"
    )

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      log.destroy!
    end
  end

  # AUD-003: Chain integrity tests
  test "should maintain chain integrity" do
    user = User.create!(
      email: "test@example.com",
      name: "Test User",
      password: "Strong@Pass123",
      data_processing_consent: true
    )

    log1 = AuditLog.log(action: "test1", user: user, status: "success")
    log2 = AuditLog.log(action: "test2", user: user, status: "success")

    assert_equal log1.checksum, log2.previous_checksum
    assert log2.verify_chain
  end
end
