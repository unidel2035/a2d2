require "test_helper"

class CollaboratorTest < ActiveSupport::TestCase
  def setup
    @spreadsheet = create(:spreadsheet)
    @user = create(:user)
    @collaborator = create(:collaborator, spreadsheet: @spreadsheet, user_id: @user.id, permission: "view")
  end

  test "should be valid with required attributes" do
    assert @collaborator.valid?
  end

  test "should require permission" do
    @collaborator.permission = nil
    assert_not @collaborator.valid?
    assert_includes @collaborator.errors[:permission], "can't be blank"
  end

  test "should only allow valid permissions" do
    assert @collaborator.update(permission: "view")
    assert @collaborator.update(permission: "edit")
    assert @collaborator.update(permission: "admin")

    @collaborator.permission = "invalid"
    assert_not @collaborator.valid?
    assert_includes @collaborator.errors[:permission], "is not included in the list"
  end

  test "should require either user_id or email" do
    collaborator = build(:collaborator, spreadsheet: @spreadsheet, user_id: nil, email: nil)
    assert_not collaborator.valid?
    assert_includes collaborator.errors[:base], "Either user_id or email must be present"
  end

  test "should be valid with only user_id" do
    collaborator = build(:collaborator, spreadsheet: @spreadsheet, user_id: @user.id, email: nil)
    assert collaborator.valid?
  end

  test "should be valid with only email" do
    collaborator = build(:collaborator, spreadsheet: @spreadsheet, user_id: nil, email: "test@example.com")
    assert collaborator.valid?
  end

  test "should enforce unique user_id per spreadsheet" do
    duplicate = build(:collaborator, spreadsheet: @spreadsheet, user_id: @user.id)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  test "should allow same user_id for different spreadsheets" do
    other_spreadsheet = create(:spreadsheet)
    other_collaborator = build(:collaborator, spreadsheet: other_spreadsheet, user_id: @user.id)
    assert other_collaborator.valid?
  end

  test "should enforce unique email per spreadsheet" do
    email_collaborator = create(:collaborator, spreadsheet: @spreadsheet, user_id: nil, email: "unique@example.com")
    duplicate = build(:collaborator, spreadsheet: @spreadsheet, user_id: nil, email: "unique@example.com")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "can_view? should return true for view, edit, and admin permissions" do
    @collaborator.permission = "view"
    assert @collaborator.can_view?

    @collaborator.permission = "edit"
    assert @collaborator.can_view?

    @collaborator.permission = "admin"
    assert @collaborator.can_view?
  end

  test "can_edit? should return true for edit and admin permissions" do
    @collaborator.permission = "view"
    assert_not @collaborator.can_edit?

    @collaborator.permission = "edit"
    assert @collaborator.can_edit?

    @collaborator.permission = "admin"
    assert @collaborator.can_edit?
  end

  test "can_admin? should return true only for admin permission" do
    @collaborator.permission = "view"
    assert_not @collaborator.can_admin?

    @collaborator.permission = "edit"
    assert_not @collaborator.can_admin?

    @collaborator.permission = "admin"
    assert @collaborator.can_admin?
  end

  test "scope with_permission should filter by permission" do
    admin_collab = create(:collaborator, spreadsheet: @spreadsheet, user_id: create(:user).id, permission: "admin")
    view_collab = create(:collaborator, spreadsheet: @spreadsheet, user_id: create(:user).id, permission: "view")

    admins = Collaborator.with_permission("admin")
    assert_includes admins, admin_collab
    assert_not_includes admins, view_collab
  end

  test "scope can_edit should return edit and admin collaborators" do
    create(:collaborator, spreadsheet: @spreadsheet, user_id: create(:user).id, permission: "view")
    edit_collab = create(:collaborator, spreadsheet: @spreadsheet, user_id: create(:user).id, permission: "edit")
    admin_collab = create(:collaborator, spreadsheet: @spreadsheet, user_id: create(:user).id, permission: "admin")

    can_edit = Collaborator.can_edit
    assert_includes can_edit, edit_collab
    assert_includes can_edit, admin_collab
  end

  test "scope can_admin should return only admin collaborators" do
    create(:collaborator, spreadsheet: @spreadsheet, user_id: create(:user).id, permission: "view")
    create(:collaborator, spreadsheet: @spreadsheet, user_id: create(:user).id, permission: "edit")
    admin_collab = create(:collaborator, spreadsheet: @spreadsheet, user_id: create(:user).id, permission: "admin")

    admins = Collaborator.can_admin
    assert_includes admins, admin_collab
    assert_equal 1, admins.where(spreadsheet: @spreadsheet).count
  end
end
