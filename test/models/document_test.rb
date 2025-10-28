require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      name: "Test User",
      email: "test@example.com",
      password: "password123",
      first_name: "Test",
      last_name: "User",
      role: :admin
    )
    @document = Document.create!(
      title: "Test Document",
      category: :passport,
      user: @user,
      status: :draft
    )
  end

  test "should be valid with valid attributes" do
    assert @document.valid?
  end

  test "should require title" do
    @document.title = nil
    assert_not @document.valid?
    assert_includes @document.errors[:title], "can't be blank"
  end

  test "should require category" do
    @document.category = nil
    assert_not @document.valid?
  end

  test "should have default version number of 1" do
    assert_equal 1, @document.version_number
  end

  test "should create new version" do
    new_version = @document.create_new_version!
    assert_equal @document.id, new_version.parent_id
    assert_equal 2, new_version.version_number
  end

  test "should get latest version" do
    version2 = @document.create_new_version!
    version3 = @document.create_new_version!

    assert_equal version3, @document.latest_version
  end

  test "should check if expired" do
    @document.expiry_date = 1.day.ago
    assert @document.expired?

    @document.expiry_date = 1.day.from_now
    assert_not @document.expired?
  end

  test "should scope active documents" do
    active_doc = Document.create!(title: "Active", category: :manual, user: @user, status: :active)
    archived_doc = Document.create!(title: "Archived", category: :manual, user: @user, status: :archived)

    assert_includes Document.active, active_doc
    assert_not_includes Document.active, archived_doc
  end

  test "should scope expiring soon" do
    @document.update!(expiry_date: 20.days.from_now, status: :active)
    assert_includes Document.expiring_soon, @document

    @document.update!(expiry_date: 40.days.from_now)
    assert_not_includes Document.expiring_soon, @document
  end
end
