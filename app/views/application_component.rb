# frozen_string_literal: true

class ApplicationComponent < Phlex::HTML
  # Include PhlexyUI to enable short-form component syntax
  # This allows us to use Button, Card, etc. instead of PhlexyUI::Button
  include PhlexyUI

  # Helper method to generate Rails URL helpers
  # This is needed because Phlex components don't have access to Rails helpers by default
  if defined?(Rails)
    include Rails.application.routes.url_helpers
    include Phlex::Rails::Helpers::Routes

    # Register Rails helper methods as output helpers
    register_output_helper :csrf_meta_tags
    register_output_helper :csp_meta_tag
    register_output_helper :stylesheet_link_tag
    register_output_helper :javascript_importmap_tags

    # Register value helpers for path methods
    register_value_helper :signup_path
    register_value_helper :login_path
    register_value_helper :logout_path
    register_value_helper :dashboard_path
    register_value_helper :components_path
    register_value_helper :spreadsheets_path
    register_value_helper :root_path
    register_value_helper :form_authenticity_token
  end
end

