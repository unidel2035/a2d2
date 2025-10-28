# frozen_string_literal: true

# Devise Warden callbacks for authentication event logging
# AUD-002: User activity logging for authentication events
Warden::Manager.after_set_user do |user, auth, opts|
  # Log successful login
  AuditLog.log(
    action: "login",
    user: user,
    auditable: user,
    ip_address: auth.request.remote_ip,
    user_agent: auth.request.user_agent,
    request_id: auth.request.request_id,
    metadata: { scope: opts[:scope], event: opts[:event] },
    status: "success"
  )
end

Warden::Manager.before_failure do |env, opts|
  # Log failed login attempt
  request = ActionDispatch::Request.new(env)
  email = request.params.dig("user", "email")
  user = User.find_by(email: email) if email

  AuditLog.log(
    action: "login_failure",
    user: user,
    auditable: user,
    ip_address: request.remote_ip,
    user_agent: request.user_agent,
    request_id: request.request_id,
    metadata: { scope: opts[:scope], message: opts[:message] },
    status: "failure",
    error_message: opts[:message].to_s
  )
end

Warden::Manager.before_logout do |user, auth, opts|
  # Log logout
  AuditLog.log(
    action: "logout",
    user: user,
    auditable: user,
    ip_address: auth.request.remote_ip,
    user_agent: auth.request.user_agent,
    request_id: auth.request.request_id,
    metadata: { scope: opts[:scope] },
    status: "success"
  )
end
