require "test_helper"

class LlmRequestTest < ActiveSupport::TestCase
  def setup
    @request = LlmRequest.new(
      provider: "openai",
      model: "gpt-4o-mini",
      prompt_tokens: 100,
      completion_tokens: 50,
      total_tokens: 150,
      status: "success"
    )
  end

  test "valid request" do
    assert @request.valid?
  end

  test "requires provider" do
    @request.provider = nil
    assert_not @request.valid?
  end

  test "requires model" do
    @request.model = nil
    assert_not @request.valid?
  end

  test "scopes filter correctly" do
    @request.save!

    assert_includes LlmRequest.by_provider("openai"), @request
    assert_includes LlmRequest.by_model("gpt-4o-mini"), @request
    assert_includes LlmRequest.successful, @request
  end
end
