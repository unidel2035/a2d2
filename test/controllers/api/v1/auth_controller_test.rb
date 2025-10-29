# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class AuthControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = User.create!(
          email: "test@example.com",
          password: "Password123!",
          password_confirmation: "Password123!",
          name: "Test User",
          role: :admin,
          data_processing_consent: true
        )

        # Пропускаем подтверждение email если используется Devise confirmable
        @user.skip_confirmation! if @user.respond_to?(:skip_confirmation!)
        @user.save!
      end

      teardown do
        User.destroy_all
        TokenBlacklist.destroy_all
      end

      # Login tests
      test "should login with valid credentials" do
        post "/api/v1/auth/login", params: {
          email: @user.email,
          password: "Password123!"
        }

        assert_response :success
        json_response = JSON.parse(response.body)

        assert_not_nil json_response["access_token"]
        assert_not_nil json_response["refresh_token"]
        assert_equal "Bearer", json_response["token_type"]
        assert_equal 86400, json_response["expires_in"]
        assert_equal @user.id, json_response["user"]["id"]
        assert_equal @user.email, json_response["user"]["email"]
      end

      test "should not login with invalid email" do
        post "/api/v1/auth/login", params: {
          email: "wrong@example.com",
          password: "Password123!"
        }

        assert_response :unauthorized
        json_response = JSON.parse(response.body)
        assert_equal "Неверный email или пароль", json_response["error"]
      end

      test "should not login with invalid password" do
        post "/api/v1/auth/login", params: {
          email: @user.email,
          password: "WrongPassword"
        }

        assert_response :unauthorized
        json_response = JSON.parse(response.body)
        assert_equal "Неверный email или пароль", json_response["error"]
      end

      # Logout tests
      test "should logout with valid token" do
        # Получаем токен
        post "/api/v1/auth/login", params: {
          email: @user.email,
          password: "Password123!"
        }
        token = JSON.parse(response.body)["access_token"]

        # Выходим
        post "/api/v1/auth/logout", headers: {
          "Authorization" => "Bearer #{token}"
        }

        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal "Успешный выход из системы", json_response["message"]

        # Проверяем, что токен добавлен в blacklist
        decoded = JsonWebToken.decode(token)
        assert TokenBlacklist.blacklisted?(decoded[:jti])
      end

      test "should not logout without token" do
        post "/api/v1/auth/logout"

        assert_response :unauthorized
        json_response = JSON.parse(response.body)
        assert_equal "Токен не предоставлен", json_response["error"]
      end

      test "should not logout with invalid token" do
        post "/api/v1/auth/logout", headers: {
          "Authorization" => "Bearer invalid.token.here"
        }

        assert_response :unauthorized
      end

      # Refresh tests
      test "should refresh token with valid refresh_token" do
        # Получаем токены
        post "/api/v1/auth/login", params: {
          email: @user.email,
          password: "Password123!"
        }
        refresh_token = JSON.parse(response.body)["refresh_token"]

        # Обновляем access токен
        post "/api/v1/auth/refresh", params: {
          refresh_token: refresh_token
        }

        assert_response :success
        json_response = JSON.parse(response.body)

        assert_not_nil json_response["access_token"]
        assert_equal "Bearer", json_response["token_type"]
        assert_equal 86400, json_response["expires_in"]
      end

      test "should not refresh without refresh_token" do
        post "/api/v1/auth/refresh"

        assert_response :bad_request
        json_response = JSON.parse(response.body)
        assert_equal "Refresh токен не предоставлен", json_response["error"]
      end

      test "should not refresh with invalid refresh_token" do
        post "/api/v1/auth/refresh", params: {
          refresh_token: "invalid.token.here"
        }

        assert_response :unauthorized
      end

      test "should not refresh with blacklisted refresh_token" do
        # Получаем refresh токен
        post "/api/v1/auth/login", params: {
          email: @user.email,
          password: "Password123!"
        }
        refresh_token = JSON.parse(response.body)["refresh_token"]

        # Добавляем его в blacklist
        decoded = JsonWebToken.decode(refresh_token)
        TokenBlacklist.add(
          jti: decoded[:jti],
          user_id: @user.id,
          expires_at: Time.at(decoded[:exp])
        )

        # Пытаемся обновить токен
        post "/api/v1/auth/refresh", params: {
          refresh_token: refresh_token
        }

        assert_response :unauthorized
        json_response = JSON.parse(response.body)
        assert_equal "Refresh токен был отозван", json_response["error"]
      end

      test "should not use blacklisted token for logout" do
        # Получаем токен
        post "/api/v1/auth/login", params: {
          email: @user.email,
          password: "Password123!"
        }
        token = JSON.parse(response.body)["access_token"]

        # Добавляем в blacklist
        decoded = JsonWebToken.decode(token)
        TokenBlacklist.add(
          jti: decoded[:jti],
          user_id: @user.id,
          expires_at: Time.at(decoded[:exp])
        )

        # Пытаемся выйти с blacklisted токеном
        post "/api/v1/auth/logout", headers: {
          "Authorization" => "Bearer #{token}"
        }

        assert_response :unauthorized
      end

      test "tokens should contain user_id and be decodable" do
        post "/api/v1/auth/login", params: {
          email: @user.email,
          password: "Password123!"
        }

        access_token = JSON.parse(response.body)["access_token"]
        refresh_token = JSON.parse(response.body)["refresh_token"]

        access_decoded = JsonWebToken.decode(access_token)
        refresh_decoded = JsonWebToken.decode(refresh_token)

        assert_equal @user.id, access_decoded[:user_id]
        assert_equal @user.id, refresh_decoded[:user_id]
        assert_equal "refresh", refresh_decoded[:type]
      end
    end
  end
end
