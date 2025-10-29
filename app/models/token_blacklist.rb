# frozen_string_literal: true

# TokenBlacklist модель для хранения отозванных JWT токенов
# Используется для инвалидации токенов при logout
class TokenBlacklist < ApplicationRecord
  belongs_to :user

  validates :jti, presence: true, uniqueness: true
  validates :expires_at, presence: true

  # Scope для получения только активных (не истекших) blacklist записей
  scope :active, -> { where("expires_at > ?", Time.current) }

  # Scope для получения истекших blacklist записей
  scope :expired, -> { where("expires_at <= ?", Time.current) }

  # Проверка, находится ли токен в blacklist и не истек ли он
  def self.blacklisted?(jti)
    active.exists?(jti: jti)
  end

  # Добавление токена в blacklist
  # @param jti [String] JWT ID токена
  # @param user_id [Integer] ID пользователя
  # @param expires_at [Time] Время истечения токена
  def self.add(jti:, user_id:, expires_at:)
    create!(jti: jti, user_id: user_id, expires_at: expires_at)
  rescue ActiveRecord::RecordNotUnique
    # Токен уже в blacklist, ничего не делаем
    Rails.logger.info("Token #{jti} is already blacklisted")
  end

  # Очистка истекших токенов из blacklist
  # Рекомендуется запускать периодически (например, через cron job)
  def self.cleanup_expired
    deleted_count = expired.delete_all
    Rails.logger.info("Cleaned up #{deleted_count} expired tokens from blacklist")
    deleted_count
  end
end
