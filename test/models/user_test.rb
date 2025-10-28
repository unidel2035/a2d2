require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      name: "Test User",
      email: "user@example.com",
      password: "password123",
      first_name: "Test",
      last_name: "User",
      role: :operator,
      license_number: "LIC-12345",
      license_expiry: 1.year.from_now
    )
  end

  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should require email" do
    @user.email = nil
    assert_not @user.valid?
  end

  test "should require unique email" do
    @user.save!
    duplicate = User.new(
      name: "Another User",
      email: "user@example.com",
      password: "password123"
    )
    assert_not duplicate.valid?
  end

  test "should require minimum password length" do
    @user.password = "short"
    assert_not @user.valid?
    assert_includes @user.errors[:password], "is too short (minimum is 8 characters)"
  end

  test "should return full name" do
    assert_equal "Test User", @user.full_name
  end

  test "should check license validity" do
    assert @user.license_valid?

    @user.license_expiry = 1.day.ago
    assert_not @user.license_valid?

    @user.license_number = nil
    assert_not @user.license_valid?
  end

  test "should check if license expired" do
    @user.license_expiry = 1.day.ago
    assert @user.license_expired?

    @user.license_expiry = 1.day.from_now
    assert_not @user.license_expired?
  end

  test "should check operator permissions" do
    @user.role = :operator
    @user.save!
    assert @user.can_operate?

    @user.role = :viewer
    assert_not @user.can_operate?
  end

  test "should check maintenance permissions" do
    @user.role = :technician
    @user.save!
    assert @user.can_maintain?

    @user.role = :operator
    assert_not @user.can_maintain?
  end

  test "should check admin permissions" do
    @user.role = :admin
    @user.save!
    assert @user.can_admin?

    @user.role = :operator
    assert_not @user.can_admin?
  end

  test "should scope active operators" do
    @user.save!
    viewer = User.create!(
      name: "Viewer",
      email: "viewer@example.com",
      password: "password123",
      role: :viewer
    )

    operators = User.active_operators
    assert_includes operators, @user
    assert_not_includes operators, viewer
  end

  test "should scope license expiring soon" do
    @user.license_expiry = 20.days.from_now
    @user.save!

    far_future = User.create!(
      name: "Future",
      email: "future@example.com",
      password: "password123",
      license_expiry: 60.days.from_now
    )

    expiring = User.license_expiring_soon
    assert_includes expiring, @user
    assert_not_includes expiring, far_future
  end
end
