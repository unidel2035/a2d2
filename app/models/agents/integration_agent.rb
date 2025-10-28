module Agents
  class IntegrationAgent < Agent
    def initialize(attributes = {})
      super
      self.type ||= "Agents::IntegrationAgent"
      self.capabilities ||= {
        rest_api: true,
        graphql: true,
        webhook_handling: true,
        message_queue: true,
        database_connectors: true
      }
    end

    def execute(task)
      integration_type = task.input_data["integration_type"]

      case integration_type
      when "rest"
        handle_rest_request(task.input_data)
      when "graphql"
        handle_graphql_request(task.input_data)
      when "webhook"
        handle_webhook(task.input_data)
      when "database"
        handle_database_query(task.input_data)
      else
        { error: "Unknown integration type: #{integration_type}" }
      end
    end

    private

    def handle_rest_request(params)
      url = params["url"]
      method = (params["method"] || "GET").upcase
      headers = params["headers"] || {}
      body = params["body"]
      auth = params["auth"]

      return { error: "URL is required" } unless url

      # Add authentication if provided
      if auth
        case auth["type"]
        when "bearer"
          headers["Authorization"] = "Bearer #{auth['token']}"
        when "basic"
          require "base64"
          credentials = Base64.strict_encode64("#{auth['username']}:#{auth['password']}")
          headers["Authorization"] = "Basic #{credentials}"
        when "api_key"
          headers[auth["header_name"] || "X-API-Key"] = auth["api_key"]
        end
      end

      # Make the request
      response = case method
      when "GET"
        HTTParty.get(url, headers: headers)
      when "POST"
        HTTParty.post(url, headers: headers, body: body.to_json)
      when "PUT"
        HTTParty.put(url, headers: headers, body: body.to_json)
      when "PATCH"
        HTTParty.patch(url, headers: headers, body: body.to_json)
      when "DELETE"
        HTTParty.delete(url, headers: headers)
      else
        return { error: "Unsupported HTTP method: #{method}" }
      end

      {
        success: response.success?,
        status_code: response.code,
        headers: response.headers.to_h,
        body: parse_response_body(response),
        request: {
          url: url,
          method: method
        }
      }
    rescue StandardError => e
      { error: "REST request failed: #{e.message}" }
    end

    def parse_response_body(response)
      return nil if response.body.nil? || response.body.empty?

      case response.headers["content-type"]
      when /json/
        JSON.parse(response.body)
      else
        response.body
      end
    rescue JSON::ParserError
      response.body
    end

    def handle_graphql_request(params)
      url = params["url"]
      query = params["query"]
      variables = params["variables"] || {}
      headers = params["headers"] || {}

      return { error: "URL and query are required" } unless url && query

      body = {
        query: query,
        variables: variables
      }

      response = HTTParty.post(
        url,
        headers: headers.merge({ "Content-Type" => "application/json" }),
        body: body.to_json
      )

      result = JSON.parse(response.body)

      {
        success: result["errors"].nil?,
        data: result["data"],
        errors: result["errors"],
        request: {
          url: url,
          query: query
        }
      }
    rescue StandardError => e
      { error: "GraphQL request failed: #{e.message}" }
    end

    def handle_webhook(params)
      # Webhook handling logic
      payload = params["payload"]
      event_type = params["event_type"]
      signature = params["signature"]
      secret = params["secret"]

      # Verify signature if secret is provided
      if secret && signature
        require "openssl"
        computed_signature = OpenSSL::HMAC.hexdigest(
          OpenSSL::Digest.new("sha256"),
          secret,
          payload.to_json
        )

        unless secure_compare(signature, "sha256=#{computed_signature}")
          return { error: "Invalid webhook signature", verified: false }
        end
      end

      {
        success: true,
        verified: secret.present?,
        event_type: event_type,
        payload: payload,
        processed_at: Time.current
      }
    rescue StandardError => e
      { error: "Webhook handling failed: #{e.message}" }
    end

    def secure_compare(a, b)
      return false if a.nil? || b.nil? || a.length != b.length

      result = 0
      a.bytes.zip(b.bytes) { |x, y| result |= x ^ y }
      result.zero?
    end

    def handle_database_query(params)
      db_type = params["db_type"]
      connection_string = params["connection_string"]
      query = params["query"]

      return { error: "Database type, connection string, and query are required" } unless db_type && connection_string && query

      case db_type.downcase
      when "postgresql", "postgres"
        execute_postgresql_query(connection_string, query)
      when "mysql"
        execute_mysql_query(connection_string, query)
      when "sqlite"
        execute_sqlite_query(connection_string, query)
      else
        { error: "Unsupported database type: #{db_type}" }
      end
    end

    def execute_postgresql_query(connection_string, query)
      require "pg"

      conn = PG.connect(connection_string)
      result = conn.exec(query)

      rows = result.map { |row| row }
      {
        success: true,
        rows: rows,
        row_count: rows.size,
        fields: result.fields
      }
    rescue StandardError => e
      { error: "PostgreSQL query failed: #{e.message}" }
    ensure
      conn&.close
    end

    def execute_mysql_query(connection_string, query)
      require "mysql2"

      # Parse connection string (simplified)
      client = Mysql2::Client.new(
        host: extract_from_connection_string(connection_string, "host"),
        username: extract_from_connection_string(connection_string, "username"),
        password: extract_from_connection_string(connection_string, "password"),
        database: extract_from_connection_string(connection_string, "database")
      )

      results = client.query(query)
      rows = results.to_a

      {
        success: true,
        rows: rows,
        row_count: rows.size,
        fields: results.fields
      }
    rescue StandardError => e
      { error: "MySQL query failed: #{e.message}" }
    ensure
      client&.close
    end

    def execute_sqlite_query(connection_string, query)
      require "sqlite3"

      db = SQLite3::Database.new(connection_string)
      db.results_as_hash = true

      rows = db.execute(query)

      {
        success: true,
        rows: rows,
        row_count: rows.size
      }
    rescue StandardError => e
      { error: "SQLite query failed: #{e.message}" }
    ensure
      db&.close
    end

    def extract_from_connection_string(conn_str, param)
      # Simple extraction for MySQL connection strings
      # Format: mysql://username:password@host:port/database
      case param
      when "host"
        conn_str[/@(.*?)(:|\/|$)/, 1] || "localhost"
      when "username"
        conn_str[/\/\/(.*?):/, 1] || "root"
      when "password"
        conn_str[/:\/\/.*?:(.*?)@/, 1] || ""
      when "database"
        conn_str[/\/([^\/\?]+)(\?|$)/, 1]
      end
    end
  end
end
