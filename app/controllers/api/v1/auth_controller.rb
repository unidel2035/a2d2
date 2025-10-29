# frozen_string_literal: true

module Api
  module V1
    # AuthController - контроллер для аутентификации через JWT токены
    # Предоставляет endpoints для login, logout и refresh токенов
    class AuthController < ApplicationController
      skip_before_action :verify_authenticity_token
      skip_before_action :require_login

      # Аутентифицирует только для logout и refresh
      before_action :authenticate_api_user_for_protected_actions, only: [ :logout, :refresh ]

      # POST /api/v1/auth/login
      # Вход пользователя и получение JWT токена
      # Параметры: email, password
      # Возвращает: token, refresh_token, user
      def login
        user = User.find_by(email: params[:email])

        unless user&.valid_password?(params[:password])
          return render json: { error: "Неверный email или пароль" }, status: :unauthorized
        end

        # Проверка подтверждения email (если включено)
        if user.respond_to?(:confirmed?) && !user.confirmed?
          return render json: { error: "Email не подтвержден" }, status: :unauthorized
        end

        # Проверка блокировки аккаунта
        if user.respond_to?(:access_locked?) && user.access_locked?
          return render json: { error: "Аккаунт заблокирован" }, status: :unauthorized
        end

        # Генерация access и refresh токенов
        access_token_data = JsonWebToken.encode({ user_id: user.id }, 24.hours.from_now)
        refresh_token_data = JsonWebToken.encode({ user_id: user.id, type: "refresh" }, 7.days.from_now)

        render json: {
          access_token: access_token_data[:token],
          refresh_token: refresh_token_data[:token],
          token_type: "Bearer",
          expires_in: 86400, # 24 часа в секундах
          user: user_json(user)
        }, status: :ok
      end

      # POST /api/v1/auth/logout
      # Выход пользователя и инвалидация токена
      # Требует: Authorization header с JWT токеном
      # Возвращает: сообщение об успехе
      def logout
        token = extract_token_from_header
        decoded = JsonWebToken.decode(token)

        if decoded && decoded[:jti]
          # Добавляем токен в blacklist
          TokenBlacklist.add(
            jti: decoded[:jti],
            user_id: @current_user.id,
            expires_at: Time.at(decoded[:exp])
          )
        end

        render json: { message: "Успешный выход из системы" }, status: :ok
      end

      # POST /api/v1/auth/refresh
      # Обновление access токена с помощью refresh токена
      # Параметры: refresh_token
      # Возвращает: новый access_token
      def refresh
        refresh_token = params[:refresh_token]

        unless refresh_token
          return render json: { error: "Refresh токен не предоставлен" }, status: :bad_request
        end

        decoded = JsonWebToken.decode(refresh_token)

        unless decoded && decoded[:type] == "refresh"
          return render json: { error: "Недействительный refresh токен" }, status: :unauthorized
        end

        # Проверка на blacklist
        if decoded[:jti] && TokenBlacklist.blacklisted?(decoded[:jti])
          return render json: { error: "Refresh токен был отозван" }, status: :unauthorized
        end

        user = User.find_by(id: decoded[:user_id])

        unless user
          return render json: { error: "Пользователь не найден" }, status: :unauthorized
        end

        # Генерация нового access токена
        access_token_data = JsonWebToken.encode({ user_id: user.id }, 24.hours.from_now)

        render json: {
          access_token: access_token_data[:token],
          token_type: "Bearer",
          expires_in: 86400 # 24 часа в секундах
        }, status: :ok
      end

      private

      # Аутентификация пользователя для защищенных действий
      def authenticate_api_user_for_protected_actions
        token = extract_token_from_header
        return render_unauthorized("Токен не предоставлен") unless token

        decoded = JsonWebToken.decode(token)
        return render_unauthorized("Недействительный токен") unless decoded

        # Проверка на blacklist
        if decoded[:jti] && TokenBlacklist.blacklisted?(decoded[:jti])
          return render_unauthorized("Токен был отозван")
        end

        @current_user = User.find_by(id: decoded[:user_id])
        return render_unauthorized("Пользователь не найден") unless @current_user
      end

      # Извлечение токена из заголовка Authorization
      def extract_token_from_header
        auth_header = request.headers["Authorization"]
        return nil unless auth_header&.start_with?("Bearer ")

        auth_header.split(" ").last
      end

      # Рендер ошибки авторизации
      def render_unauthorized(message = "Не авторизован")
        render json: { error: message }, status: :unauthorized
      end

      # Формирование JSON для пользователя
      def user_json(user)
        {
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role
        }
      end
    end
  end
end
