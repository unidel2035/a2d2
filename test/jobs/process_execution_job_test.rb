require "test_helper"

class ProcessExecutionJobTest < ActiveJob::TestCase
  def setup
    @process = create(:process)
    @process_execution = create(:process_execution, process: @process)
  end

  test "job should be enqueued" do
    assert_enqueued_with(job: ProcessExecutionJob, args: [@process_execution.id]) do
      ProcessExecutionJob.perform_later(@process_execution.id)
    end
  end

  test "job should execute successfully with valid process_execution" do
    assert_nothing_raised do
      ProcessExecutionJob.perform_now(@process_execution.id)
    end
  end

  test "job should handle missing process_execution gracefully" do
    assert_nothing_raised do
      ProcessExecutionJob.perform_now(999999)
    end
  end

  test "job should use correct queue" do
    assert_equal "default", ProcessExecutionJob.new.queue_name
  end
end
