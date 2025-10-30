require "test_helper"

class Landing::IndexViewTest < ActiveSupport::TestCase
  test "renders landing page title" do
    view = Landing::IndexView.new
    html = view.call

    assert_includes html, "A2D2"
    assert_includes html, "Automation to Automation Delivery"
  end

  test "renders hero section with description" do
    view = Landing::IndexView.new
    html = view.call

    assert_includes html, "Платформа автоматизации автоматизации"
    assert_includes html, "интеллектуальными агентами"
    assert_includes html, "Ruby on Rails"
  end

  test "renders GitHub button" do
    view = Landing::IndexView.new
    html = view.call

    assert_includes html, "GitHub"
    assert_includes html, "https://github.com/unidel2035/a2d2"
  end

  test "renders statistics section" do
    view = Landing::IndexView.new
    html = view.call

    assert_includes html, "8.1"
    assert_includes html, "MIT"
    assert_includes html, "Современный стек"
  end

  test "renders key features" do
    view = Landing::IndexView.new
    html = view.call

    # Проверяем все 6 ключевых функций
    assert_includes html, "Ключевые преимущества платформы"
    assert_includes html, "🤖 Автоматизация автоматизации"
    assert_includes html, "🔌 Единый API для всех LLM"
    assert_includes html, "🧠 Интеллектуальные агенты"
    assert_includes html, "🔄 Самоорганизующаяся экосистема"
    assert_includes html, "📦 Готовые решения из коробки"
    assert_includes html, "🛡️ Технологический суверенитет"
  end

  test "renders tech stack categories" do
    view = Landing::IndexView.new
    html = view.call

    assert_includes html, "Современный технологический стек"
    assert_includes html, "🔧 Backend"
    assert_includes html, "🎨 Frontend"
    assert_includes html, "🔐 AI & Security"
  end

  test "renders backend technologies" do
    view = Landing::IndexView.new
    html = view.call

    assert_includes html, "Ruby 3.3.6"
    assert_includes html, "Rails 8.1.0"
    assert_includes html, "Puma 7.1.0"
    assert_includes html, "Solid Queue"
  end

  test "renders frontend technologies" do
    view = Landing::IndexView.new
    html = view.call

    assert_includes html, "Phlex"
    assert_includes html, "PhlexyUI"
    assert_includes html, "Turbo"
    assert_includes html, "Stimulus"
  end

  test "renders AI and security technologies" do
    view = Landing::IndexView.new
    html = view.call

    assert_includes html, "OpenAI API"
    assert_includes html, "Anthropic Claude API"
    assert_includes html, "Devise"
    assert_includes html, "Pundit"
  end

  test "renders quick start steps" do
    view = Landing::IndexView.new
    html = view.call

    assert_includes html, "Быстрый старт"
    assert_includes html, "Шаг 1"
    assert_includes html, "Шаг 2"
    assert_includes html, "Шаг 3"
    assert_includes html, "Шаг 4"
  end

  test "renders installation commands" do
    view = Landing::IndexView.new
    html = view.call

    assert_includes html, "git clone https://github.com/unidel2035/a2d2.git"
    assert_includes html, "bundle install"
    assert_includes html, "bin/rails db:setup"
    assert_includes html, "bin/dev"
  end

  test "renders system requirements" do
    view = Landing::IndexView.new
    html = view.call

    assert_includes html, "Системные требования"
    assert_includes html, "Ruby 3.3.6+"
    assert_includes html, "Rails 8.1.0"
  end

  test "renders footer with links" do
    view = Landing::IndexView.new
    html = view.call

    assert_includes html, "Документация"
    assert_includes html, "Issues"
    assert_includes html, "Discussions"
    assert_includes html, "© 2025 A2D2"
    assert_includes html, "MIT License"
  end

  test "does not include gradient classes" do
    view = Landing::IndexView.new
    html = view.call

    # Проверяем отсутствие градиентных классов
    assert_not_includes html, "bg-gradient-to-br"
    assert_not_includes html, "bg-gradient-to-r"
    assert_not_includes html, "bg-clip-text"
  end

  test "does not include purple color classes" do
    view = Landing::IndexView.new
    html = view.call

    # Проверяем отсутствие цветных классов (кроме neutral и success)
    # Ищем прямое использование primary/secondary/accent в цветах текста и границ
    refute_match(/text-primary(?!-)/, html) # text-primary, но не text-primary-content
    refute_match(/text-secondary(?!-)/, html)
    refute_match(/text-accent(?!-)/, html)
    refute_match(/border-primary(?!-)/, html)
    refute_match(/border-secondary(?!-)/, html)
    refute_match(/border-accent(?!-)/, html)
  end

  test "uses neutral color scheme" do
    view = Landing::IndexView.new
    html = view.call

    # Проверяем использование нейтральных цветов
    assert_includes html, "btn-neutral"
    assert_includes html, "badge-neutral"
    assert_includes html, "text-base-content"
  end

  test "all cards have consistent styling" do
    view = Landing::IndexView.new
    html = view.call

    # Проверяем, что все карточки имеют границы и тени
    assert_includes html, "border border-base-300"
    assert_includes html, "shadow-lg"
  end
end
