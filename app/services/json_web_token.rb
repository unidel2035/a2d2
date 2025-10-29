# frozen_string_literal: true

# JsonWebToken service для работы с JWT токенами
# Используется для аутентификации API запросов
class JsonWebToken
  # Секретный ключ для подписи JWT токенов
  SECRET_KEY = Rails.application.credentials.secret_key_base.to_s

  # Кодирует payload в JWT токен
  # @param payload [Hash] Данные для кодирования (обычно user_id)
  # @param exp [ActiveSupport::TimeWithZone] Время истечения токена (по умолчанию 24 часа)
  # @return [Hash] Хеш с токеном и jti (JWT ID)
  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    payload[:jti] ||= SecureRandom.uuid # Генерируем уникальный ID для токена
    token = JWT.encode(payload, SECRET_KEY)
    { token: token, jti: payload[:jti], exp: payload[:exp] }
  end

  # Декодирует JWT токен
  # @param token [String] JWT токен для декодирования
  # @return [HashWithIndifferentAccess, nil] Декодированный payload или nil при ошибке
  def self.decode(token)
    body = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(body)
  rescue JWT::DecodeError => e
    Rails.logger.error("JWT decode error: #{e.message}")
    nil
  end
end
