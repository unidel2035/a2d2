# frozen_string_literal: true

# Pundit configuration for authorization
# AUTH-002: RBAC (Role-Based Access Control)
ActiveSupport.on_load(:action_controller) do
  include Pundit::Authorization

  # Rescue from authorization errors
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "Вы не авторизованы для выполнения этого действия."
    redirect_back(fallback_location: root_path)
  end
end
