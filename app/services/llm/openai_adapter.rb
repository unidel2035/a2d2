module Llm
  class OpenaiAdapter < BaseAdapter
    def provider_name
      "openai"
    end

    def default_api_key
      ENV["OPENAI_API_KEY"]
    end

    def chat(messages:, temperature: 0.7, max_tokens: nil, **options)
      client = OpenAI::Client.new(access_token: api_key)

      params = {
        model: model,
        messages: messages,
        temperature: temperature
      }
      params[:max_tokens] = max_tokens if max_tokens

      response = client.chat(parameters: params.merge(options))
      parse_response(response)
    rescue StandardError => e
      { error: e.message, provider: provider_name }
    end

    private

    def extract_content(response)
      response.dig("choices", 0, "message", "content")
    end

    def extract_usage(response)
      {
        prompt_tokens: response.dig("usage", "prompt_tokens"),
        completion_tokens: response.dig("usage", "completion_tokens"),
        total_tokens: response.dig("usage", "total_tokens")
      }
    end

    def extract_model(response)
      response["model"] || @model
    end
  end
end
