# frozen_string_literal: true

require "test_helper"

class JsonWebTokenTest < ActiveSupport::TestCase
  setup do
    @user_id = 1
    @payload = { user_id: @user_id }
  end

  test "encode creates a valid JWT token with jti" do
    result = JsonWebToken.encode(@payload)

    assert_not_nil result
    assert result.is_a?(Hash)
    assert_not_nil result[:token]
    assert_not_nil result[:jti]
    assert_not_nil result[:exp]
  end

  test "encode includes expiration time" do
    exp_time = 2.hours.from_now
    result = JsonWebToken.encode(@payload, exp_time)

    assert_equal exp_time.to_i, result[:exp]
  end

  test "encode generates unique jti for each token" do
    result1 = JsonWebToken.encode(@payload.dup)
    result2 = JsonWebToken.encode(@payload.dup)

    assert_not_equal result1[:jti], result2[:jti]
  end

  test "decode returns payload from valid token" do
    encoded = JsonWebToken.encode(@payload)
    decoded = JsonWebToken.decode(encoded[:token])

    assert_not_nil decoded
    assert_equal @user_id, decoded[:user_id]
    assert_not_nil decoded[:jti]
    assert_not_nil decoded[:exp]
  end

  test "decode returns HashWithIndifferentAccess" do
    encoded = JsonWebToken.encode(@payload)
    decoded = JsonWebToken.decode(encoded[:token])

    assert decoded.is_a?(HashWithIndifferentAccess)
    assert_equal decoded[:user_id], decoded["user_id"]
  end

  test "decode returns nil for invalid token" do
    invalid_token = "invalid.jwt.token"
    decoded = JsonWebToken.decode(invalid_token)

    assert_nil decoded
  end

  test "decode returns nil for expired token" do
    exp_time = 1.second.ago
    encoded = JsonWebToken.encode(@payload, exp_time)

    sleep 1

    decoded = JsonWebToken.decode(encoded[:token])

    # JWT.decode will raise an error for expired tokens, which our method catches
    assert_nil decoded
  end

  test "decode returns nil for tampered token" do
    encoded = JsonWebToken.encode(@payload)
    tampered_token = encoded[:token] + "tampered"

    decoded = JsonWebToken.decode(tampered_token)

    assert_nil decoded
  end

  test "encode preserves custom payload fields" do
    custom_payload = { user_id: @user_id, role: "admin", custom_field: "value" }
    encoded = JsonWebToken.encode(custom_payload)
    decoded = JsonWebToken.decode(encoded[:token])

    assert_equal "admin", decoded[:role]
    assert_equal "value", decoded[:custom_field]
  end

  test "jti is preserved in payload if provided" do
    custom_jti = SecureRandom.uuid
    payload_with_jti = @payload.merge(jti: custom_jti)
    encoded = JsonWebToken.encode(payload_with_jti)

    assert_equal custom_jti, encoded[:jti]
  end
end
