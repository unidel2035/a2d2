# frozen_string_literal: true

# Devise configuration for A2D2 platform
# AUTH-001: Multi-factor authentication
# AUTH-002: Session management
# AUTH-006: Session timeout

Devise.setup do |config|
  # The secret key used by Devise. Devise uses this key to generate
  # random tokens. Changing this key will render invalid all existing
  # confirmation, reset password and unlock tokens in the database.
  config.secret_key = Rails.application.credentials.devise_secret_key || ENV["DEVISE_SECRET_KEY"]

  # ==> Mailer Configuration
  config.mailer_sender = "noreply@a2d2.example.com"

  # ==> ORM configuration
  require "devise/orm/active_record"

  # ==> Configuration for any authentication mechanism
  # Configure which keys are used when authenticating a user.
  config.authentication_keys = [:email]

  # Configure parameters from the request object used for authentication.
  config.request_keys = []

  # If http headers should be returned for AJAX requests. True by default.
  config.http_authenticatable_on_xhr = false

  # Disable remember me functionality (for security)
  # Users must re-authenticate after session expires
  config.remember_for = 0

  # The time you want to timeout the user session without activity.
  # AUTH-006: Session timeout - 30 minutes
  config.timeout_in = 30.minutes

  # ==> Configuration for :database_authenticatable
  # Define which will be the encryption algorithm. Devise uses bcrypt.
  config.stretches = Rails.env.test? ? 1 : 12

  # Send a notification when the user's password is changed.
  config.send_password_change_notification = true

  # Send notification to the original user when another user's email is changed.
  config.send_email_changed_notification = true

  # ==> Configuration for :validatable
  # Range for password length.
  config.password_length = 8..128

  # Email regex used to validate email formats. It asserts that there is
  # one (and only one) @ symbol in the email string.
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  # ==> Configuration for :timeoutable
  # The time you want to timeout the user session without activity.
  config.timeout_in = 30.minutes

  # ==> Configuration for :lockable
  # Defines which strategy will be used to lock an account.
  config.lock_strategy = :failed_attempts

  # Defines which key will be used when locking and unlocking an account
  config.unlock_keys = [:email]

  # Defines which strategy will be used to unlock an account.
  config.unlock_strategy = :both

  # Number of authentication tries before locking an account
  config.maximum_attempts = 5

  # Time interval to unlock the account if :time is enabled as unlock_strategy.
  config.unlock_in = 1.hour

  # Warn on the last attempt before the account is locked.
  config.last_attempt_warning = true

  # ==> Configuration for :recoverable
  # Defines which key will be used when recovering the password for an account
  config.reset_password_keys = [:email]

  # Time interval you can reset your password with a reset password key.
  config.reset_password_within = 6.hours

  # When set to false, does not sign a user in automatically after their password is
  # reset. Defaults to true, so a user is signed in automatically after a reset.
  config.sign_in_after_reset_password = true

  # ==> Configuration for :confirmable
  # A period that the user is allowed to access the website even without
  # confirming their account. For instance, if set to 2.days, the user will be
  # able to access the website for two days without confirming their account,
  # access will be blocked just in the third day.
  config.allow_unconfirmed_access_for = 2.days

  # ==> Configuration for :omniauthable
  # Add OAuth providers as needed (AUTH-003)
  # config.omniauth :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"]

  # ==> Security Configuration
  # Use paranoid mode - doesn't reveal if a user exists on failed authentication
  config.paranoid = true

  # Configure the e-mail address which will be shown in Devise::Mailer
  config.mailer_sender = "noreply@a2d2.example.com"

  # ==> Navigation configuration
  # Default sign out path after user signs out
  config.sign_out_via = :delete

  # ==> Warden configuration
  # If you want to use other strategies, that are not supported by Devise, or
  # change the failure app, you can configure them inside the config.warden block.
  config.warden do |manager|
    manager.failure_app = Devise::FailureApp
    # manager.intercept_401 = false
    # manager.default_strategies(scope: :user).unshift :some_external_strategy
  end
end
