# frozen_string_literal: true

# Permissions-Policy configuration
# Controls which browser features can be used
# Note: Rails' built-in permissions_policy sets the Feature-Policy header (old name)
# For better browser compatibility, we also set Permissions-Policy header manually

# Configure using Rails' native permissions_policy
Rails.application.config.permissions_policy do |policy|
  policy.camera :none
  policy.geolocation :none
  policy.microphone :none
  policy.payment :none
  # Note: USB is not supported in Rails' permissions_policy DSL
  # It will be set manually below
end

# Additionally set the modern Permissions-Policy header format
# This is more compatible with modern browsers
Rails.application.config.action_dispatch.default_headers.merge!(
  'Permissions-Policy' => 'camera=(), geolocation=(), microphone=(), payment=(), usb=()'
)
