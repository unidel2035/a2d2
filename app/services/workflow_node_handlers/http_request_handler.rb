# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module WorkflowNodeHandlers
  # Handler for HTTP request nodes - similar to n8n's HTTP Request node
  class HttpRequestHandler < BaseHandler
    def execute(input_data, parameters, execution_context)
      url = evaluate_expression(parameters['url'], input_data)
      method = (parameters['method'] || 'GET').upcase
      headers = parameters['headers'] || {}
      body = parameters['body']

      # Evaluate expressions in headers and body
      headers = evaluate_headers(headers, input_data)
      body = evaluate_body(body, input_data) if body

      response = make_request(url, method, headers, body)

      {
        data: parse_response(response),
        output: parse_response(response),
        status_code: response.code.to_i,
        headers: response.to_hash
      }
    rescue StandardError => e
      {
        data: { error: e.message },
        output: { error: e.message },
        error: e.message
      }
    end

    private

    def make_request(url, method, headers, body)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'

      request = build_request(uri, method)

      # Set headers
      headers.each { |key, value| request[key] = value }

      # Set body for POST/PUT/PATCH
      request.body = body if body && %w[POST PUT PATCH].include?(method)

      http.request(request)
    end

    def build_request(uri, method)
      case method
      when 'GET'
        Net::HTTP::Get.new(uri)
      when 'POST'
        Net::HTTP::Post.new(uri)
      when 'PUT'
        Net::HTTP::Put.new(uri)
      when 'PATCH'
        Net::HTTP::Patch.new(uri)
      when 'DELETE'
        Net::HTTP::Delete.new(uri)
      else
        Net::HTTP::Get.new(uri)
      end
    end

    def evaluate_headers(headers, data)
      return {} unless headers.is_a?(Hash)

      headers.transform_values do |value|
        evaluate_expression(value, data)
      end
    end

    def evaluate_body(body, data)
      if body.is_a?(String)
        evaluate_expression(body, data)
      elsif body.is_a?(Hash)
        body.transform_values { |v| evaluate_expression(v, data) }.to_json
      else
        body.to_json
      end
    end

    def parse_response(response)
      content_type = response['content-type']

      if content_type&.include?('application/json')
        JSON.parse(response.body)
      else
        { body: response.body }
      end
    rescue JSON::ParserError
      { body: response.body }
    end
  end
end
