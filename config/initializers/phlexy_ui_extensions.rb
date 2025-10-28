# frozen_string_literal: true

# Load custom PhlexyUI component extensions
# Rails will autoload them from app/views/components/phlexy_ui_extensions/
# But we need to eager load them in production and make them available in PhlexyUI module

Rails.application.config.to_prepare do
  Dir[Rails.root.join("app/views/components/phlexy_ui_extensions/*.rb")].sort.each do |file|
    load file
  end
end
