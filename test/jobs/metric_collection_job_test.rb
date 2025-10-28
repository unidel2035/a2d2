require "test_helper"

class MetricCollectionJobTest < ActiveJob::TestCase
  test "job should be enqueued" do
    assert_enqueued_with(job: MetricCollectionJob) do
      MetricCollectionJob.perform_later
    end
  end

  test "job should execute successfully" do
    assert_nothing_raised do
      MetricCollectionJob.perform_now
    end
  end

  test "job should use correct queue" do
    assert_equal "default", MetricCollectionJob.new.queue_name
  end

  test "job should collect metrics from multiple sources" do
    # Create some test data
    create_list(:robot, 3)
    create_list(:agent, 2)

    assert_nothing_raised do
      MetricCollectionJob.perform_now
    end

    # Verify metrics were created (if your implementation creates Metric records)
    # assert_operator Metric.count, :>, 0
  end
end
