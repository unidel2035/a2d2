# frozen_string_literal: true

# ApiAuthentication concern для аутентификации API запросов через JWT токены
# Используется в API контроллерах для защиты endpoints
module ApiAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_api_user
  end

  private

  # Аутентификация пользователя по JWT токену
  # Извлекает токен из заголовка Authorization и проверяет его валидность
  def authenticate_api_user
    token = extract_token_from_header
    return render_unauthorized("Токен не предоставлен") unless token

    decoded = JsonWebToken.decode(token)
    return render_unauthorized("Недействительный токен") unless decoded

    # Проверка на blacklist
    if TokenBlacklist.exists?(jti: decoded[:jti])
      return render_unauthorized("Токен был отозван")
    end

    @current_user = User.find_by(id: decoded[:user_id])
    return render_unauthorized("Пользователь не найден") unless @current_user

    # Обновляем время последней активности
    @current_user.touch(:last_activity_at) if @current_user.respond_to?(:last_activity_at)
  rescue ActiveRecord::RecordNotFound
    render_unauthorized("Пользователь не найден")
  end

  # Текущий аутентифицированный пользователь
  def current_user
    @current_user
  end

  # Проверка аутентификации
  def user_signed_in?
    @current_user.present?
  end

  # Извлечение токена из заголовка Authorization
  # Формат: "Bearer <token>"
  def extract_token_from_header
    auth_header = request.headers["Authorization"]
    return nil unless auth_header&.start_with?("Bearer ")

    auth_header.split(" ").last
  end

  # Рендер ошибки авторизации
  def render_unauthorized(message = "Не авторизован")
    render json: { error: message }, status: :unauthorized
  end
end
