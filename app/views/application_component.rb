# frozen_string_literal: true

class ApplicationComponent < Phlex::HTML
  # Include PhlexyUI to enable short-form component syntax
  # This allows us to use Button, Card, etc. instead of PhlexyUI::Button
  include PhlexyUI

  # Helper method to generate Rails URL helpers
  # This is needed because Phlex components don't have access to Rails helpers by default
  if defined?(Rails)
    include Rails.application.routes.url_helpers
  end
end
