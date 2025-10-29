# frozen_string_literal: true

require "test_helper"

class TokenBlacklistTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      email: "test@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      name: "Test User",
      role: :admin,
      data_processing_consent: true
    )
    @jti = SecureRandom.uuid
    @expires_at = 1.day.from_now
  end

  teardown do
    TokenBlacklist.destroy_all
    User.destroy_all
  end

  test "should create token blacklist entry" do
    blacklist = TokenBlacklist.create(
      jti: @jti,
      user: @user,
      expires_at: @expires_at
    )

    assert blacklist.persisted?
    assert_equal @jti, blacklist.jti
    assert_equal @user.id, blacklist.user_id
  end

  test "should require jti" do
    blacklist = TokenBlacklist.new(
      user: @user,
      expires_at: @expires_at
    )

    assert_not blacklist.valid?
    assert_includes blacklist.errors[:jti], "can't be blank"
  end

  test "should require unique jti" do
    TokenBlacklist.create!(
      jti: @jti,
      user: @user,
      expires_at: @expires_at
    )

    duplicate = TokenBlacklist.new(
      jti: @jti,
      user: @user,
      expires_at: @expires_at
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:jti], "has already been taken"
  end

  test "should require expires_at" do
    blacklist = TokenBlacklist.new(
      jti: @jti,
      user: @user
    )

    assert_not blacklist.valid?
    assert_includes blacklist.errors[:expires_at], "can't be blank"
  end

  test "active scope returns only non-expired tokens" do
    # Активный токен
    active = TokenBlacklist.create!(
      jti: SecureRandom.uuid,
      user: @user,
      expires_at: 1.day.from_now
    )

    # Истекший токен
    expired = TokenBlacklist.create!(
      jti: SecureRandom.uuid,
      user: @user,
      expires_at: 1.day.ago
    )

    active_tokens = TokenBlacklist.active
    assert_includes active_tokens, active
    assert_not_includes active_tokens, expired
  end

  test "expired scope returns only expired tokens" do
    # Активный токен
    active = TokenBlacklist.create!(
      jti: SecureRandom.uuid,
      user: @user,
      expires_at: 1.day.from_now
    )

    # Истекший токен
    expired = TokenBlacklist.create!(
      jti: SecureRandom.uuid,
      user: @user,
      expires_at: 1.day.ago
    )

    expired_tokens = TokenBlacklist.expired
    assert_includes expired_tokens, expired
    assert_not_includes expired_tokens, active
  end

  test "blacklisted? returns true for blacklisted and active token" do
    TokenBlacklist.create!(
      jti: @jti,
      user: @user,
      expires_at: 1.day.from_now
    )

    assert TokenBlacklist.blacklisted?(@jti)
  end

  test "blacklisted? returns false for non-blacklisted token" do
    assert_not TokenBlacklist.blacklisted?("non-existent-jti")
  end

  test "blacklisted? returns false for expired blacklisted token" do
    TokenBlacklist.create!(
      jti: @jti,
      user: @user,
      expires_at: 1.day.ago
    )

    assert_not TokenBlacklist.blacklisted?(@jti)
  end

  test "add creates a new blacklist entry" do
    TokenBlacklist.add(
      jti: @jti,
      user_id: @user.id,
      expires_at: @expires_at
    )

    assert TokenBlacklist.exists?(jti: @jti)
  end

  test "add handles duplicate jti gracefully" do
    TokenBlacklist.add(
      jti: @jti,
      user_id: @user.id,
      expires_at: @expires_at
    )

    # Не должно выбросить исключение
    assert_nothing_raised do
      TokenBlacklist.add(
        jti: @jti,
        user_id: @user.id,
        expires_at: @expires_at
      )
    end

    # Должна быть только одна запись
    assert_equal 1, TokenBlacklist.where(jti: @jti).count
  end

  test "cleanup_expired removes expired tokens" do
    # Создаем активные токены
    active1 = TokenBlacklist.create!(
      jti: SecureRandom.uuid,
      user: @user,
      expires_at: 1.day.from_now
    )

    active2 = TokenBlacklist.create!(
      jti: SecureRandom.uuid,
      user: @user,
      expires_at: 2.days.from_now
    )

    # Создаем истекшие токены
    expired1 = TokenBlacklist.create!(
      jti: SecureRandom.uuid,
      user: @user,
      expires_at: 1.day.ago
    )

    expired2 = TokenBlacklist.create!(
      jti: SecureRandom.uuid,
      user: @user,
      expires_at: 2.days.ago
    )

    deleted_count = TokenBlacklist.cleanup_expired

    assert_equal 2, deleted_count
    assert TokenBlacklist.exists?(active1.id)
    assert TokenBlacklist.exists?(active2.id)
    assert_not TokenBlacklist.exists?(expired1.id)
    assert_not TokenBlacklist.exists?(expired2.id)
  end

  test "belongs_to user" do
    blacklist = TokenBlacklist.create!(
      jti: @jti,
      user: @user,
      expires_at: @expires_at
    )

    assert_equal @user, blacklist.user
  end
end
