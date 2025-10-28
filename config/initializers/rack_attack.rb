# frozen_string_literal: true

# Rack::Attack configuration for rate limiting and security
# Rate limiting helps prevent brute force attacks and API abuse
class Rack::Attack
  # Always allow requests from localhost in development
  safelist("allow from localhost") do |req|
    req.ip == "127.0.0.1" || req.ip == "::1" if Rails.env.development?
  end

  # Throttle login attempts by email address
  # AUTH-001: Protect against brute force attacks
  throttle("logins/email", limit: 5, period: 20.minutes) do |req|
    if req.path == "/users/sign_in" && req.post?
      # Return the email as the discriminator
      req.params["user"]&.dig("email")&.downcase
    end
  end

  # Throttle login attempts by IP address
  throttle("logins/ip", limit: 20, period: 20.minutes) do |req|
    req.ip if req.path == "/users/sign_in" && req.post?
  end

  # Throttle password reset requests
  throttle("password_resets/email", limit: 3, period: 1.hour) do |req|
    if req.path == "/users/password" && req.post?
      req.params["user"]&.dig("email")&.downcase
    end
  end

  # Throttle API requests
  # AUTH-005: API rate limiting
  throttle("api/ip", limit: 300, period: 5.minutes) do |req|
    req.ip if req.path.start_with?("/api/")
  end

  # Throttle by authenticated API token
  throttle("api/token", limit: 1000, period: 1.hour) do |req|
    if req.path.start_with?("/api/")
      # Extract token from Authorization header
      token = req.env["HTTP_AUTHORIZATION"]&.split(" ")&.last
      User.find_by_api_token(token)&.id if token
    end
  end

  # Block suspicious requests
  blocklist("block suspicious requests") do |req|
    # Block requests with suspicious User-Agents
    suspicious_agents = ["<script>", "curl", "wget"]
    suspicious_agents.any? { |agent| req.user_agent&.include?(agent) }
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |env|
    retry_after = env["rack.attack.match_data"][:period]
    [
      429,
      {
        "Content-Type" => "application/json",
        "Retry-After" => retry_after.to_s
      },
      [{ error: "Слишком много запросов. Попробуйте позже.", retry_after: retry_after }.to_json]
    ]
  end

  # Custom response for blocked requests
  self.blocklisted_responder = lambda do |_env|
    [
      403,
      { "Content-Type" => "application/json" },
      [{ error: "Запрос заблокирован по соображениям безопасности." }.to_json]
    ]
  end

  # Track requests (optional, for monitoring)
  ActiveSupport::Notifications.subscribe("rack.attack") do |_name, _start, _finish, _request_id, payload|
    req = payload[:request]
    if [:throttle, :blocklist].include?(req.env["rack.attack.match_type"])
      Rails.logger.warn(
        "[Rack::Attack] #{req.env['rack.attack.match_type']}: " \
        "#{req.ip} #{req.request_method} #{req.fullpath} " \
        "matched: #{req.env['rack.attack.matched']}"
      )
    end
  end
end

# Enable Rack::Attack
Rails.application.config.middleware.use Rack::Attack
