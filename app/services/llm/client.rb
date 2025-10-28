module Llm
  class Client
    # Pricing per 1M tokens (input/output) in USD
    PRICING = {
      openai: {
        "gpt-4o": { prompt: 2.50, completion: 10.00 },
        "gpt-4o-mini": { prompt: 0.15, completion: 0.60 },
        "gpt-4-turbo": { prompt: 10.00, completion: 30.00 },
        "gpt-3.5-turbo": { prompt: 0.50, completion: 1.50 }
      },
      anthropic: {
        "claude-3-5-sonnet-20241022": { prompt: 3.00, completion: 15.00 },
        "claude-3-opus-20240229": { prompt: 15.00, completion: 75.00 },
        "claude-3-haiku-20240307": { prompt: 0.25, completion: 1.25 }
      },
      deepseek: {
        "deepseek-chat": { prompt: 0.14, completion: 0.28 },
        "deepseek-coder": { prompt: 0.14, completion: 0.28 }
      },
      gemini: {
        "gemini-1.5-pro": { prompt: 1.25, completion: 5.00 },
        "gemini-1.5-flash": { prompt: 0.075, completion: 0.30 }
      },
      grok: {
        "grok-beta": { prompt: 5.00, completion: 15.00 }
      },
      mistral: {
        "mistral-large-latest": { prompt: 2.00, completion: 6.00 },
        "mistral-small-latest": { prompt: 0.20, completion: 0.60 }
      }
    }.freeze

    # Default routing rules (provider => model)
    DEFAULT_ROUTES = {
      fast: { provider: :openai, model: "gpt-4o-mini" },
      balanced: { provider: :anthropic, model: "claude-3-5-sonnet-20241022" },
      powerful: { provider: :openai, model: "gpt-4o" },
      cost_effective: { provider: :deepseek, model: "deepseek-chat" }
    }.freeze

    # Fallback chain for each provider
    FALLBACK_CHAINS = {
      openai: [ :anthropic, :deepseek, :mistral ],
      anthropic: [ :openai, :deepseek, :mistral ],
      deepseek: [ :openai, :mistral, :anthropic ],
      gemini: [ :openai, :anthropic, :mistral ],
      grok: [ :openai, :anthropic, :deepseek ],
      mistral: [ :openai, :deepseek, :anthropic ]
    }.freeze

    attr_reader :provider, :model, :adapter

    def initialize(provider: :openai, model: nil, route: nil)
      if route
        route_config = DEFAULT_ROUTES[route.to_sym]
        @provider = route_config[:provider]
        @model = route_config[:model]
      else
        @provider = provider.to_sym
        @model = model || default_model_for_provider(@provider)
      end

      @adapter = create_adapter(@provider, @model)
    end

    def chat(messages:, agent_task: nil, **options)
      start_time = Time.current
      attempts = [ @provider ] + (FALLBACK_CHAINS[@provider] || [])

      attempts.each_with_index do |current_provider, index|
        begin
          current_adapter = index.zero? ? @adapter : create_adapter(current_provider, default_model_for_provider(current_provider))

          # Check rate limit before making request
          if rate_limited?(current_provider)
            Rails.logger.warn "Rate limited for #{current_provider}, trying next provider"
            next
          end

          response = current_adapter.chat(messages: messages, **options)

          if response[:error]
            Rails.logger.error "LLM request failed for #{current_provider}: #{response[:error]}"
            next unless index == attempts.size - 1 # Try next provider
          end

          # Track the request
          track_request(
            provider: current_adapter.provider_name,
            model: response[:model] || current_adapter.model,
            usage: response[:usage],
            response_time: ((Time.current - start_time) * 1000).to_i,
            status: "success",
            agent_task: agent_task
          )

          return response
        rescue StandardError => e
          Rails.logger.error "Exception in LLM request for #{current_provider}: #{e.message}"
          next unless index == attempts.size - 1
          raise e
        end
      end

      # All attempts failed
      track_request(
        provider: @adapter.provider_name,
        model: @model,
        usage: {},
        response_time: ((Time.current - start_time) * 1000).to_i,
        status: "error",
        error_message: "All providers failed",
        agent_task: agent_task
      )

      { error: "All LLM providers failed", provider: @provider }
    end

    private

    def create_adapter(provider, model)
      case provider
      when :openai
        Llm::OpenaiAdapter.new(model: model)
      when :anthropic
        Llm::AnthropicAdapter.new(model: model)
      when :deepseek
        Llm::DeepseekAdapter.new(model: model)
      when :gemini
        Llm::GeminiAdapter.new(model: model)
      when :grok
        Llm::GrokAdapter.new(model: model)
      when :mistral
        Llm::MistralAdapter.new(model: model)
      else
        raise ArgumentError, "Unknown provider: #{provider}"
      end
    end

    def default_model_for_provider(provider)
      case provider
      when :openai then "gpt-4o-mini"
      when :anthropic then "claude-3-5-sonnet-20241022"
      when :deepseek then "deepseek-chat"
      when :gemini then "gemini-1.5-flash"
      when :grok then "grok-beta"
      when :mistral then "mistral-small-latest"
      else "gpt-4o-mini"
      end
    end

    def rate_limited?(provider)
      # Check if we've hit rate limit in the last minute
      recent_requests = LlmRequest
        .where(provider: provider.to_s)
        .where("created_at > ?", 1.minute.ago)
        .count

      # Simple rate limiting: max 60 requests per minute per provider
      recent_requests >= 60
    end

    def track_request(provider:, model:, usage:, response_time:, status:, agent_task: nil, error_message: nil)
      LlmRequest.create!(
        agent_task: agent_task,
        provider: provider,
        model: model,
        prompt_tokens: usage[:prompt_tokens],
        completion_tokens: usage[:completion_tokens],
        total_tokens: usage[:total_tokens],
        response_time_ms: response_time,
        status: status,
        error_message: error_message
      )
    end
  end
end
