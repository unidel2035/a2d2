# frozen_string_literal: true

# SecureHeaders configuration
# ENC-001: TLS 1.3 with HSTS
# Security headers to protect against common vulnerabilities
SecureHeaders::Configuration.default do |config|
  # Strict-Transport-Security (HSTS)
  # Forces HTTPS for 1 year, include subdomains
  config.hsts = "max-age=#{1.year.to_i}; includeSubDomains; preload"

  # X-Frame-Options
  # Prevents clickjacking attacks
  config.x_frame_options = "DENY"

  # X-Content-Type-Options
  # Prevents MIME-sniffing
  config.x_content_type_options = "nosniff"

  # X-XSS-Protection
  # Enables XSS filter in browsers
  config.x_xss_protection = "1; mode=block"

  # X-Download-Options
  # Prevents IE from executing downloads
  config.x_download_options = "noopen"

  # X-Permitted-Cross-Domain-Policies
  # Restricts Flash and PDF cross-domain policies
  config.x_permitted_cross_domain_policies = "none"

  # Referrer-Policy
  # Controls referrer information
  config.referrer_policy = "strict-origin-when-cross-origin"

  # Content-Security-Policy (CSP)
  # Comprehensive policy to prevent XSS and other code injection attacks
  config.csp = {
    default_src: %w['self'],
    script_src: %w['self' 'unsafe-inline' https://cdn.jsdelivr.net],
    style_src: %w['self' 'unsafe-inline' https://cdn.jsdelivr.net],
    img_src: %w['self' data: https:],
    font_src: %w['self' data: https://cdn.jsdelivr.net],
    connect_src: %w['self'],
    frame_ancestors: %w['none'],
    base_uri: %w['self'],
    form_action: %w['self'],
    upgrade_insecure_requests: true
  }

  # Note: Permissions-Policy is not supported by secure_headers gem version 6.5
  # It needs to be configured separately using Rails' native permissions_policy
  # See config/initializers/permissions_policy.rb

  # Note: Expect-CT header is deprecated since Chrome 107 (2022)
  # Chrome now enforces Certificate Transparency by default
  # This configuration is removed as it's no longer needed
end

# Override for development environment if needed
if Rails.env.development?
  SecureHeaders::Configuration.override(:development) do |config|
    # Relax CSP for development with hot-reloading
    config.csp[:connect_src] = %w['self' ws: wss:]
  end
end
