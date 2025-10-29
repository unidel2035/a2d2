require "test_helper"

class DocumentClassificationJobTest < ActiveJob::TestCase
  def setup
    @document = create(:document)
  end

  test "job should be enqueued" do
    assert_enqueued_with(job: DocumentClassificationJob, args: [@document.id]) do
      DocumentClassificationJob.perform_later(@document.id)
    end
  end

  test "job should execute successfully with valid document" do
    assert_nothing_raised do
      DocumentClassificationJob.perform_now(@document.id)
    end
  end

  test "job should handle missing document gracefully" do
    assert_nothing_raised do
      DocumentClassificationJob.perform_now(999999)
    end
  end

  test "job should use correct queue" do
    assert_equal "default", DocumentClassificationJob.new.queue_name
  end
end
