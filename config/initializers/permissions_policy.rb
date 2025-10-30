# frozen_string_literal: true

# Permissions-Policy configuration
# Controls which browser features can be used
# Note: We only use the modern Permissions-Policy header, not the deprecated Feature-Policy

# Disable the deprecated Feature-Policy header that Rails generates
Rails.application.config.permissions_policy do |policy|
  # Empty configuration to prevent Rails from setting Feature-Policy header
end

# Set only the modern Permissions-Policy header
# This prevents the warning about duplicate policies
Rails.application.config.action_dispatch.default_headers.merge!(
  'Permissions-Policy' => 'camera=(), geolocation=(), microphone=(), payment=(), usb=()'
)
