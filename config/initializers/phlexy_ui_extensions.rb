# frozen_string_literal: true

# Load custom PhlexyUI component extensions
Dir[Rails.root.join("app/views/components/phlexy_ui_extensions/*.rb")].sort.each do |file|
  require file
end
