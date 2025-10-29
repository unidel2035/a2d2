require "test_helper"

module Llm
  class ClientTest < ActiveSupport::TestCase
    def setup
      @client = Llm::Client.new(provider: :openai, model: "gpt-4o-mini")
    end

    test "should initialize with provider and model" do
      assert_equal :openai, @client.provider
      assert_equal "gpt-4o-mini", @client.model
      assert_not_nil @client.adapter
    end

    test "should initialize with route" do
      client = Llm::Client.new(route: :fast)
      assert_equal :openai, client.provider
      assert_equal "gpt-4o-mini", client.model
    end

    test "should use default model when not specified" do
      client = Llm::Client.new(provider: :anthropic)
      assert_equal "claude-3-5-sonnet-20241022", client.model
    end

    test "should raise error for unknown provider" do
      assert_raises(ArgumentError) do
        Llm::Client.new(provider: :unknown)
      end
    end

    test "should have pricing defined for all providers" do
      assert_includes Llm::Client::PRICING.keys, :openai
      assert_includes Llm::Client::PRICING.keys, :anthropic
      assert_includes Llm::Client::PRICING.keys, :deepseek
      assert_includes Llm::Client::PRICING.keys, :gemini
      assert_includes Llm::Client::PRICING.keys, :grok
      assert_includes Llm::Client::PRICING.keys, :mistral
    end

    test "should have default routes defined" do
      assert_includes Llm::Client::DEFAULT_ROUTES.keys, :fast
      assert_includes Llm::Client::DEFAULT_ROUTES.keys, :balanced
      assert_includes Llm::Client::DEFAULT_ROUTES.keys, :powerful
      assert_includes Llm::Client::DEFAULT_ROUTES.keys, :cost_effective
    end

    test "should have fallback chains defined" do
      assert_includes Llm::Client::FALLBACK_CHAINS.keys, :openai
      assert_includes Llm::Client::FALLBACK_CHAINS.keys, :anthropic
      assert_includes Llm::Client::FALLBACK_CHAINS.keys, :deepseek
    end

    test "should track failed requests" do
      # This would require mocking the adapter's chat method to fail
      # and verifying that LlmRequest.create! is called with error status
      skip "Requires adapter mocking"
    end

    test "should implement rate limiting" do
      # Create 60+ requests in the last minute to test rate limiting
      skip "Requires setup of 60+ requests and adapter mocking"
    end
  end
end
