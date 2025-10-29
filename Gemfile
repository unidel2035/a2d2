source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.0"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use sqlite3 as the database for Active Record
gem "sqlite3", ">= 2.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Authentication and Authorization - AUTH-001 to AUTH-006
gem "devise", "~> 4.9"
gem "devise-two-factor", github: "devise-two-factor/devise-two-factor"
gem "pundit", "~> 2.3"
gem "rqrcode", "~> 2.0" # For QR code generation in MFA

# Rate limiting and security - INFRA-001, SEC-001
gem "rack-attack", "~> 6.7"
gem "secure_headers", "~> 6.5"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

# PhlexyUI - Ruby UI component library for DaisyUI using Phlex
gem "phlexy_ui"
gem "phlex-rails"

# LLM and AI integrations
gem "ruby-openai"
gem "anthropic"
gem "httparty"

# Reporting and data export
gem "prawn"
gem "prawn-table"
gem "caxlsx"
gem "caxlsx_rails"

# GraphQL client and API
gem "graphql-client"
gem "graphql", "~> 2.0" # BUS-003: GraphQL API

# Full-text search - DOC-006
gem "pg_search"

# PDF processing - DOC-002, DOC-003
gem "pdf-reader"

# OCR support - DOC-003 (Tesseract)
# Note: Requires tesseract-ocr to be installed on the system
# gem "rtesseract" # Uncomment when tesseract is available

# XML/KML generation - ROB-005
gem "builder"

# Schedule management - ANL-005
gem "whenever", require: false

# Data validation
gem "dry-validation"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"

  # Test coverage reporting
  gem "simplecov", require: false
  gem "simplecov-html", require: false

  # Factory for test data
  gem "factory_bot_rails"

  # Additional testing tools
  gem "webmock" # Mock HTTP requests
  gem "vcr" # Record HTTP interactions
  gem "shoulda-matchers" # Additional matchers for tests
  gem "faker" # Generate fake data for tests
end
