require "test_helper"

class ProcessBuilderServiceTest < ActiveSupport::TestCase
  def setup
    @process = create(:process)
    @service = ProcessBuilderService.new(@process)
  end

  test "should have available blocks" do
    blocks = ProcessBuilderService.available_blocks
    assert_not_nil blocks
    assert_includes blocks.keys, :actions
    assert_includes blocks.keys, :decisions
    assert_includes blocks.keys, :agents
    assert_includes blocks.keys, :integrations
    assert_includes blocks.keys, :control
  end

  test "available_blocks should have action blocks" do
    actions = ProcessBuilderService.available_blocks[:actions]
    assert actions.is_a?(Array)
    assert_operator actions.size, :>, 0

    first_action = actions.first
    assert_equal "action", first_action[:type]
    assert_not_nil first_action[:name]
    assert_not_nil first_action[:config_schema]
  end

  test "available_blocks should have decision blocks" do
    decisions = ProcessBuilderService.available_blocks[:decisions]
    assert decisions.is_a?(Array)
    assert_operator decisions.size, :>, 0
  end

  test "available_blocks should have agent blocks" do
    agents = ProcessBuilderService.available_blocks[:agents]
    assert agents.is_a?(Array)
    assert_operator agents.size, :>, 0

    analyzer_agent = agents.find { |a| a[:name] == "Analyze Data" }
    assert_not_nil analyzer_agent
    assert_equal "Agents::AnalyzerAgent", analyzer_agent[:agent_type]
  end

  test "add_step should create a new process step" do
    step_params = {
      name: "Test Step",
      description: "A test step",
      step_type: "action",
      configuration: { action: "test" }
    }

    assert_difference "@process.process_steps.count", 1 do
      step = @service.add_step(step_params)
      assert_not_nil step
      assert_equal "Test Step", step.name
    end
  end

  test "add_step should auto-increment order" do
    first_step = @service.add_step(name: "First", step_type: "action")
    second_step = @service.add_step(name: "Second", step_type: "action")

    assert_equal 1, first_step.order
    assert_equal 2, second_step.order
  end

  test "remove_step should delete step and reorder" do
    step1 = @service.add_step(name: "Step 1", step_type: "action")
    step2 = @service.add_step(name: "Step 2", step_type: "action")
    step3 = @service.add_step(name: "Step 3", step_type: "action")

    assert_difference "@process.process_steps.count", -1 do
      @service.remove_step(step2.id)
    end

    @process.reload
    remaining_steps = @process.process_steps.order(:order)
    assert_equal 1, remaining_steps.first.order
    assert_equal 2, remaining_steps.last.order
  end

  test "validate_process should fail for empty process" do
    result = @service.validate_process
    assert_not result[:valid]
    assert_includes result[:errors].join, "at least one step"
  end

  test "validate_process should succeed for valid process" do
    @service.add_step(
      name: "Start",
      step_type: "action",
      configuration: { action: "test" }
    )

    result = @service.validate_process
    assert result[:valid]
    assert_empty result[:errors]
  end

  test "validate_process should detect missing agent_type for agent_task steps" do
    @service.add_step(
      name: "Agent Task",
      step_type: "agent_task",
      configuration: {}
    )

    result = @service.validate_process
    assert_not result[:valid]
    assert_includes result[:errors].join, "agent_type is required"
  end

  test "validate_process should detect missing integration_id for integration steps" do
    @service.add_step(
      name: "Integration",
      step_type: "integration",
      configuration: {}
    )

    result = @service.validate_process
    assert_not result[:valid]
    assert_includes result[:errors].join, "integration_id is required"
  end

  test "validate_process should detect missing conditions for decision steps" do
    @service.add_step(
      name: "Decision",
      step_type: "decision",
      configuration: {},
      conditions: nil
    )

    result = @service.validate_process
    assert_not result[:valid]
    assert_includes result[:errors].join, "conditions are required"
  end

  test "reorder_steps should maintain sequential order" do
    step1 = create(:process_step, process: @process, order: 1)
    step2 = create(:process_step, process: @process, order: 5)
    step3 = create(:process_step, process: @process, order: 10)

    @service.reorder_steps

    step1.reload
    step2.reload
    step3.reload

    assert_equal 1, step1.order
    assert_equal 2, step2.order
    assert_equal 3, step3.order
  end
end
