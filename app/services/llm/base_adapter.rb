module Llm
  class BaseAdapter
    attr_reader :model, :api_key

    def initialize(model:, api_key: nil)
      @model = model
      @api_key = api_key || default_api_key
    end

    # Abstract method to be implemented by subclasses
    def chat(messages:, **options)
      raise NotImplementedError, "Subclasses must implement chat method"
    end

    # Abstract method to get provider name
    def provider_name
      raise NotImplementedError, "Subclasses must implement provider_name"
    end

    # Default API key from environment
    def default_api_key
      nil
    end

    # Parse response into standard format
    def parse_response(response)
      {
        content: extract_content(response),
        usage: extract_usage(response),
        model: extract_model(response)
      }
    end

    private

    def extract_content(response)
      raise NotImplementedError
    end

    def extract_usage(response)
      raise NotImplementedError
    end

    def extract_model(response)
      @model
    end
  end
end
