class ErrorsController < ApplicationController
  def not_found
    render Errors::NotFoundView.new, status: :not_found
  end

  def internal_server_error
    render Errors::InternalServerErrorView.new, status: :internal_server_error
  end

  def unprocessable_entity
    render Errors::UnprocessableEntityView.new, status: :unprocessable_entity
  end
end
