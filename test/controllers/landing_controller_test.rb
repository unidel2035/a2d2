require "test_helper"

class LandingControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get landing_url
    assert_response :success
  end

  test "should render Phlex component" do
    get landing_url
    assert_response :success
    # Проверяем, что A2D2 присутствует в ответе
    assert_match /A2D2/, response.body
  end

  test "should include hero section" do
    get landing_url
    assert_response :success
    # Проверяем наличие героя секции
    assert_match /Automation to Automation Delivery/, response.body
    assert_match /Платформа автоматизации автоматизации/, response.body
  end

  test "should include key features section" do
    get landing_url
    assert_response :success
    # Проверяем наличие секции с ключевыми преимуществами
    assert_match /Ключевые преимущества платформы/, response.body
    assert_match /Автоматизация автоматизации/, response.body
    assert_match /Единый API для всех LLM/, response.body
    assert_match /Интеллектуальные агенты/, response.body
  end

  test "should include tech stack section" do
    get landing_url
    assert_response :success
    # Проверяем наличие секции технологий
    assert_match /Современный технологический стек/, response.body
    assert_match /Ruby on Rails/, response.body
    assert_match /Phlex/, response.body
  end

  test "should include quick start section" do
    get landing_url
    assert_response :success
    # Проверяем наличие секции быстрого старта
    assert_match /Быстрый старт/, response.body
    assert_match /git clone/, response.body
    assert_match /bundle install/, response.body
  end

  test "should include GitHub link" do
    get landing_url
    assert_response :success
    # Проверяем наличие ссылки на GitHub
    assert_match /https:\/\/github\.com\/unidel2035\/a2d2/, response.body
  end

  test "should not include gradients" do
    get landing_url
    assert_response :success
    # Проверяем отсутствие градиентов в классах
    assert_no_match /bg-gradient/, response.body
    assert_no_match /gradient-to/, response.body
  end

  test "should not include purple colors" do
    get landing_url
    assert_response :success
    # Проверяем отсутствие фиолетовых цветов
    assert_no_match /text-primary|text-secondary|text-accent/, response.body
    assert_no_match /btn-primary|btn-secondary|btn-accent/, response.body
  end

  test "should use neutral colors" do
    get landing_url
    assert_response :success
    # Проверяем использование нейтральных цветов
    assert_match /btn-neutral|badge-neutral/, response.body
    assert_match /text-base-content/, response.body
  end
end
