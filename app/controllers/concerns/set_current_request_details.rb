# frozen_string_literal: true

# Controller concern to set current user and request for audit logging
# Include in ApplicationController
module SetCurrentRequestDetails
  extend ActiveSupport::Concern

  included do
    before_action :set_current_request_details
  end

  private

  def set_current_request_details
    Current.user = current_user if defined?(current_user)
    Current.request = request
  end
end
