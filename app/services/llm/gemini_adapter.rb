module Llm
  class GeminiAdapter < BaseAdapter
    BASE_URL = "https://generativelanguage.googleapis.com/v1beta"

    def provider_name
      "gemini"
    end

    def default_api_key
      ENV["GEMINI_API_KEY"]
    end

    def chat(messages:, temperature: 0.7, max_tokens: nil, **options)
      # Convert messages to Gemini format
      contents = messages.map do |msg|
        {
          role: msg[:role] == "assistant" ? "model" : "user",
          parts: [ { text: msg[:content] } ]
        }
      end

      body = {
        contents: contents,
        generationConfig: {
          temperature: temperature
        }
      }
      body[:generationConfig][:maxOutputTokens] = max_tokens if max_tokens

      response = HTTParty.post(
        "#{BASE_URL}/models/#{model}:generateContent?key=#{api_key}",
        headers: { "Content-Type" => "application/json" },
        body: body.to_json
      )

      parse_response(JSON.parse(response.body))
    rescue StandardError => e
      { error: e.message, provider: provider_name }
    end

    private

    def extract_content(response)
      response.dig("candidates", 0, "content", "parts", 0, "text")
    end

    def extract_usage(response)
      metadata = response["usageMetadata"] || {}
      {
        prompt_tokens: metadata["promptTokenCount"],
        completion_tokens: metadata["candidatesTokenCount"],
        total_tokens: metadata["totalTokenCount"]
      }
    end
  end
end
