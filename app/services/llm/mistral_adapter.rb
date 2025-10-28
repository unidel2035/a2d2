module Llm
  class MistralAdapter < BaseAdapter
    BASE_URL = "https://api.mistral.ai/v1"

    def provider_name
      "mistral"
    end

    def default_api_key
      ENV["MISTRAL_API_KEY"]
    end

    def chat(messages:, temperature: 0.7, max_tokens: nil, **options)
      headers = {
        "Authorization" => "Bearer #{api_key}",
        "Content-Type" => "application/json"
      }

      body = {
        model: model,
        messages: messages,
        temperature: temperature
      }
      body[:max_tokens] = max_tokens if max_tokens
      body.merge!(options)

      response = HTTParty.post(
        "#{BASE_URL}/chat/completions",
        headers: headers,
        body: body.to_json
      )

      parse_response(JSON.parse(response.body))
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
