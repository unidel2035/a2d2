require "test_helper"

class ProcessTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      name: "Test User",
      email: "process@example.com",
      password: "password123",
      role: :admin
    )
    @process = Process.create!(
      name: "Test Process",
      user: @user,
      status: :draft,
      definition: { description: "Test process definition" }
    )
  end

  test "should be valid with valid attributes" do
    assert @process.valid?
  end

  test "should require name" do
    @process.name = nil
    assert_not @process.valid?
  end

  test "should have default version number of 1" do
    assert_equal 1, @process.version_number
  end

  test "should create new version" do
    step = @process.process_steps.create!(
      name: "Step 1",
      step_type: "action",
      order: 1
    )

    new_version = @process.create_new_version!

    assert_equal @process.id, new_version.parent_id
    assert_equal 2, new_version.version_number
    assert_equal 1, new_version.process_steps.count
  end

  test "should execute process" do
    step = @process.process_steps.create!(
      name: "Test Step",
      step_type: "action",
      order: 1,
      configuration: { action: "test" }
    )

    execution = @process.execute!(user: @user)

    assert_instance_of ProcessExecution, execution
    assert_equal :pending, execution.status.to_sym
  end

  test "should scope active processes" do
    active = Process.create!(name: "Active", user: @user, status: :active)
    inactive = Process.create!(name: "Inactive", user: @user, status: :inactive)

    assert_includes Process.active, active
    assert_not_includes Process.active, inactive
  end
end
