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
    @robot = Robot.create!(
      manufacturer: "TestCorp",
      model: "RB-100",
      serial_number: "SN-DOC-TEST",
      status: :active
    )
    @document = Document.create!(
      title: "Test Document",
      category: :passport,
      user: @user,
      robot: @robot,
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
    active_doc = Document.create!(title: "Active", category: :manual, user: @user, robot: @robot, status: :active)
    archived_doc = Document.create!(title: "Archived", category: :manual, user: @user, robot: @robot, status: :archived)

    assert_includes Document.active, active_doc
    assert_not_includes Document.active, archived_doc
  end

  test "should scope expiring soon" do
    @document.update!(expiry_date: 20.days.from_now, status: :active)
    assert_includes Document.expiring_soon, @document

    @document.update!(expiry_date: 40.days.from_now)
    assert_not_includes Document.expiring_soon, @document
  end

  test "should belong to robot" do
    assert_equal @robot, @document.robot
  end

  test "should require robot" do
    @document.robot = nil
    assert_not @document.valid?
    assert_includes @document.errors[:robot], "can't be blank"
  end

  test "should belong to user who uploaded" do
    assert_equal @user, @document.user
  end

  # Тесты поиска согласно issue #150
  test "should search documents by title" do
    doc1 = Document.create!(
      title: "Robot Manual",
      content_text: "Instructions",
      category: :manual,
      user: @user,
      robot: @robot,
      status: :active
    )
    doc2 = Document.create!(
      title: "User Guide",
      content_text: "How to use",
      category: :manual,
      user: @user,
      robot: @robot,
      status: :active
    )

    results = Document.search("Robot")
    assert_includes results, doc1
    assert_not_includes results, doc2
  end

  test "should search documents by content" do
    doc1 = Document.create!(
      title: "Manual",
      content_text: "Robot instructions",
      category: :manual,
      user: @user,
      robot: @robot,
      status: :active
    )
    doc2 = Document.create!(
      title: "Guide",
      content_text: "User guide",
      category: :manual,
      user: @user,
      robot: @robot,
      status: :active
    )

    results = Document.search("Robot")
    assert_includes results, doc1
    assert_not_includes results, doc2
  end

  test "should return all documents when search query is blank" do
    count = Document.count
    results = Document.search("")
    assert_equal count, results.count
  end

  test "should search case insensitively" do
    doc = Document.create!(
      title: "ROBOT Manual",
      content_text: "Instructions",
      category: :manual,
      user: @user,
      robot: @robot,
      status: :active
    )

    results = Document.search("robot")
    assert_includes results, doc
  end

  test "should search in multiple fields" do
    doc = Document.create!(
      title: "Manual",
      content_text: "Instructions",
      author: "Robot Expert",
      category: :manual,
      user: @user,
      robot: @robot,
      status: :active
    )

    results = Document.search("Robot Expert")
    assert_includes results, doc
  end
end
