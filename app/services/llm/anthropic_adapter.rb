module Llm
  class AnthropicAdapter < BaseAdapter
    def provider_name
      "anthropic"
    end

    def default_api_key
      ENV["ANTHROPIC_API_KEY"]
    end

    def chat(messages:, temperature: 0.7, max_tokens: 1024, **options)
      client = Anthropic::Client.new(access_token: api_key)

      # Convert OpenAI-style messages to Anthropic format
      system_message = messages.find { |m| m[:role] == "system" }&.dig(:content)
      user_messages = messages.reject { |m| m[:role] == "system" }

      params = {
        model: model,
        messages: user_messages,
        max_tokens: max_tokens,
        temperature: temperature
      }
      params[:system] = system_message if system_message

      response = client.messages(parameters: params.merge(options))
      parse_response(response)
    rescue StandardError => e
      { error: e.message, provider: provider_name }
    end

    private

    def extract_content(response)
      response.dig("content", 0, "text")
    end

    def extract_usage(response)
      {
        prompt_tokens: response.dig("usage", "input_tokens"),
        completion_tokens: response.dig("usage", "output_tokens"),
        total_tokens: (response.dig("usage", "input_tokens") || 0) + (response.dig("usage", "output_tokens") || 0)
      }
    end

    def extract_model(response)
      response["model"] || @model
    end
  end
end
