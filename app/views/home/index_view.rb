# frozen_string_literal: true

module Home
  class IndexView < ApplicationComponent
    def initialize(logged_in: false, current_user: nil)
      @logged_in = logged_in
      @current_user = current_user
    end

    def view_template
      doctype
      html(data_theme: "light") do
        render_head
        render_body
      end
    end

    private

    def render_head
      head do
        title { "A2D2 - Платформа автоматизации автоматизации" }
        meta(name: "viewport", content: "width=device-width,initial-scale=1")
        csrf_meta_tags
        csp_meta_tag

        stylesheet_link_tag "application", data: { turbo_track: "reload" }
        script(src: "https://cdn.tailwindcss.com")
        link(
          href: "https://cdn.jsdelivr.net/npm/daisyui@4.12.14/dist/full.min.css",
          rel: "stylesheet",
          type: "text/css"
        )
        javascript_importmap_tags
      end
    end

    def render_body
      body do
        render Components::NavbarComponent.new(logged_in: @logged_in, current_user: @current_user)
        render_hero_section
        render_features_section
        render_about_section
        render_cta_section
        render Components::FooterComponent.new
      end
    end

    def render_hero_section
      div class: "relative min-h-screen bg-gradient-to-br from-purple-900 via-blue-900 to-indigo-900 overflow-hidden" do
        # Animated background particles
        div(class: "absolute inset-0 opacity-20") do
          div(class: "absolute top-1/4 left-1/4 w-96 h-96 bg-purple-500 rounded-full mix-blend-multiply filter blur-xl animate-blob")
          div(class: "absolute top-1/3 right-1/4 w-96 h-96 bg-blue-500 rounded-full mix-blend-multiply filter blur-xl animate-blob animation-delay-2000")
          div(class: "absolute bottom-1/4 left-1/3 w-96 h-96 bg-indigo-500 rounded-full mix-blend-multiply filter blur-xl animate-blob animation-delay-4000")
        end

        # Hero content
        div(class: "container mx-auto px-4 py-20 relative z-10") do
          div(class: "flex flex-col items-center justify-center min-h-screen text-center") do
            # Badge
            div(class: "mb-8 animate-fade-in") do
              Badge class: "badge-lg bg-white/10 border-white/20 text-white backdrop-blur-sm px-6 py-3" do
                plain "🚀 "
                span(class: "font-semibold") { "Платформа нового поколения" }
              end
            end

            # Main heading with gradient
            h1(class: "text-7xl md:text-8xl font-black mb-8 animate-fade-in-up") do
              div(class: "bg-gradient-to-r from-white via-blue-100 to-purple-200 bg-clip-text text-transparent") do
                "A2D2"
              end
            end

            # Subheading
            p(class: "text-3xl md:text-4xl font-bold mb-6 text-white/90 animate-fade-in-up animation-delay-200") do
              "Автоматизация автоматизации"
            end

            # Description
            p(class: "text-xl md:text-2xl mb-12 text-white/70 max-w-3xl mx-auto leading-relaxed animate-fade-in-up animation-delay-400") do
              plain "Где ИИ-агенты управляют бизнес-процессами, "
              plain "а мета-система координирует их работу. "
              br
              span(class: "text-white/90 font-semibold") { "Будущее автоматизации доступно сегодня." }
            end

            # CTA Buttons
            div(class: "flex flex-wrap gap-4 justify-center mb-16 animate-fade-in-up animation-delay-600") do
              Link href: signup_path, class: "btn btn-lg bg-gradient-to-r from-purple-500 to-blue-500 hover:from-purple-600 hover:to-blue-600 text-white border-0 shadow-2xl shadow-purple-500/50 gap-3 px-8" do
                render_icon(:lightning)
                plain "Начать работу бесплатно"
              end

              Link href: dashboard_path, class: "btn btn-lg bg-white/10 hover:bg-white/20 text-white border-white/20 backdrop-blur-sm gap-3 px-8" do
                render_icon(:grid)
                plain "Посмотреть демо"
              end
            end

            # Feature highlights
            div(class: "grid grid-cols-1 md:grid-cols-3 gap-6 max-w-4xl animate-fade-in-up animation-delay-800") do
              render_hero_feature("🤖", "ИИ-Агенты", "Интеллектуальные агенты для автоматизации")
              render_hero_feature("🔌", "Единый API", "Доступ ко всем LLM через один интерфейс")
              render_hero_feature("🛡️", "Безопасность", "Полный контроль и защита данных")
            end
          end
        end
      end
    end

    def render_hero_feature(emoji, title, description)
      div(class: "bg-white/5 backdrop-blur-lg rounded-2xl p-6 border border-white/10 hover:bg-white/10 transition-all duration-300 hover:scale-105") do
        div(class: "text-4xl mb-2") { emoji }
        h3(class: "text-lg font-bold text-white mb-1") { title }
        p(class: "text-sm text-white/60") { description }
      end
    end

    def render_features_section
      div(id: "features", class: "py-24 bg-gradient-to-b from-base-100 to-base-200") do
        div(class: "container mx-auto px-4") do
          # Section header
          div(class: "text-center mb-16") do
            h2(class: "text-5xl font-bold mb-6 bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent") do
              "Основные возможности"
            end
            p(class: "text-xl text-base-content/70 mb-4 max-w-2xl mx-auto") do
              "Полный набор инструментов для управления роботизацией и ИИ-агентами"
            end
            div(class: "flex justify-center gap-2") do
              Badge :primary, class: "badge-lg" do
                "Ruby on Rails 8"
              end
              Badge :secondary, class: "badge-lg" do
                "Solid Queue"
              end
              Badge :accent, class: "badge-lg" do
                "Turbo + Stimulus"
              end
            end
          end

          # Feature grid with enhanced cards
          div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8") do
            render_feature_card(
              "🤖",
              "Интеллектуальные агенты",
              "Система ИИ-агентов для анализа, валидации, трансформации данных и автоматической генерации отчетов",
              :primary
            )
            render_feature_card(
              "🎯",
              "Оркестрация задач",
              "Мета-слой для управления агентами, распределения задач и автоматической верификации результатов",
              :secondary
            )
            render_feature_card(
              "🔌",
              "Единый API для LLM",
              "OpenAI-совместимый интерфейс для доступа к GPT, Claude, DeepSeek, Gemini через единый API",
              :accent
            )
            render_feature_card(
              "📊",
              "Аналитика в реальном времени",
              "Дашборды, метрики производительности агентов и автоматическая генерация инсайтов",
              :info
            )
            render_feature_card(
              "🔄",
              "Процессная автоматизация",
              "Визуальный конструктор бизнес-процессов с автоматическим исполнением и мониторингом",
              :success
            )
            render_feature_card(
              "🛡️",
              "Безопасность данных",
              "Сквозное шифрование, локальная обработка и полный контроль над инфраструктурой",
              :warning
            )
          end
        end
      end
    end

    def render_feature_card(emoji, title, description, color)
      div(class: "group relative") do
        # Gradient border effect
        div(class: "absolute inset-0 bg-gradient-to-r from-#{color} to-#{color} rounded-2xl opacity-0 group-hover:opacity-20 blur transition-all duration-300")

        Card :base_100, class: "relative shadow-xl hover:shadow-2xl transition-all duration-300 group-hover:-translate-y-2 border-2 border-transparent group-hover:border-#{color}/50 h-full" do |card|
          card.body class: "flex flex-col h-full" do
            # Icon with gradient background
            div(class: "flex items-center justify-center w-16 h-16 rounded-xl bg-gradient-to-br from-#{color} to-#{color} text-#{color}-content text-3xl mb-4 group-hover:scale-110 transition-transform duration-300") do
              emoji
            end

            card.title(class: "text-2xl mb-3 group-hover:text-#{color} transition-colors") do
              title
            end

            p(class: "text-base-content/70 flex-grow leading-relaxed") do
              description
            end

            # Learn more link
            div(class: "mt-4 opacity-0 group-hover:opacity-100 transition-opacity duration-300") do
              Link href: "#", class: "text-#{color} font-semibold flex items-center gap-2" do
                plain "Узнать больше"
                span(class: "group-hover:translate-x-1 transition-transform") { "→" }
              end
            end
          end
        end
      end
    end

    def render_about_section
      div(id: "about", class: "py-24 bg-gradient-to-b from-base-200 to-base-100 relative overflow-hidden") do
        # Background pattern
        div(class: "absolute inset-0 opacity-5") do
          div(class: "absolute inset-0 bg-grid-pattern")
        end

        div(class: "container mx-auto px-4 relative z-10") do
          div(class: "max-w-5xl mx-auto") do
            # Main content
            div(class: "text-center mb-16") do
              h2(class: "text-5xl font-bold mb-8 bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent") do
                "О проекте A2D2"
              end
              p(class: "text-2xl text-base-content/80 mb-6 leading-relaxed") do
                plain "Первая российская платформа "
                span(class: "font-bold text-primary") { "«ИИ управляет ИИ»" }
                plain " на проверенном стеке Ruby on Rails"
              end
              p(class: "text-lg text-base-content/70 leading-relaxed max-w-3xl mx-auto") do
                plain "A2D2 - это платформа автоматизации автоматизации для организаций, внедряющих роботизацию "
                plain "и ИИ-агенты. Система обеспечивает управление интеллектуальными агентами, "
                plain "упрощает документооборот и автоматизирует бизнес-процессы."
              end
            end

            # Stats with enhanced design
            div(class: "grid grid-cols-1 md:grid-cols-3 gap-6") do
              render_stat("100%", "Открытый исходный код", "MIT License", :primary)
              render_stat("24/7", "Доступность системы", "Непрерывная работа", :secondary)
              render_stat("🔐", "Безопасность данных", "Полный контроль", :accent)
            end

            # Technology stack
            div(class: "mt-16 text-center") do
              p(class: "text-sm text-base-content/60 uppercase tracking-wider mb-6 font-semibold") do
                "Построено на современных технологиях"
              end
              div(class: "flex flex-wrap justify-center gap-4") do
                [ "Ruby 3.3.6", "Rails 8.1.0", "PostgreSQL", "Solid Queue", "Turbo", "Stimulus", "Tailwind CSS", "DaisyUI" ].each do |tech|
                  Badge class: "badge-lg bg-base-100 border-base-300" do
                    tech
                  end
                end
              end
            end
          end
        end
      end
    end

    def render_stat(value, title, subtitle, color)
      div(class: "group") do
        Card :base_100, class: "shadow-xl hover:shadow-2xl transition-all duration-300 group-hover:-translate-y-1 border-2 border-transparent group-hover:border-#{color}/30" do |card|
          card.body class: "text-center" do
            div(class: "text-5xl font-black mb-3 bg-gradient-to-br from-#{color} to-#{color} bg-clip-text text-transparent") do
              value
            end
            div(class: "text-xl font-bold mb-2") { title }
            div(class: "text-sm text-base-content/60") { subtitle }
          end
        end
      end
    end

    def render_cta_section
      div(class: "relative py-32 bg-gradient-to-br from-purple-600 via-blue-600 to-indigo-700 overflow-hidden") do
        # Animated background
        div(class: "absolute inset-0 opacity-10") do
          div(class: "absolute top-0 left-1/4 w-96 h-96 bg-white rounded-full mix-blend-overlay filter blur-3xl animate-pulse")
          div(class: "absolute bottom-0 right-1/4 w-96 h-96 bg-white rounded-full mix-blend-overlay filter blur-3xl animate-pulse animation-delay-2000")
        end

        div(class: "container mx-auto px-4 text-center relative z-10") do
          # Badge
          div(class: "mb-8") do
            Badge class: "badge-lg bg-white/20 border-white/30 text-white backdrop-blur-sm px-6 py-3" do
              plain "✨ "
              span(class: "font-semibold") { "Начните бесплатно" }
            end
          end

          # Main CTA heading
          h2(class: "text-6xl md:text-7xl font-black text-white mb-6 leading-tight") do
            plain "Готовы к "
            br(class: "hidden md:block")
            span(class: "bg-gradient-to-r from-yellow-200 to-pink-200 bg-clip-text text-transparent") do
              "революции"
            end
            plain " в автоматизации?"
          end

          p(class: "text-2xl text-white/90 mb-12 max-w-3xl mx-auto leading-relaxed") do
            plain "Присоединяйтесь к A2D2 и начните автоматизировать вашу автоматизацию уже сегодня. "
            br
            span(class: "font-semibold") { "Первые 30 дней бесплатно, без привязки карты." }
          end

          # CTA Buttons
          div(class: "flex flex-col sm:flex-row gap-4 justify-center mb-12") do
            Link href: signup_path, class: "btn btn-lg bg-white text-purple-600 hover:bg-gray-100 border-0 shadow-2xl gap-3 px-10" do
              plain "Создать аккаунт бесплатно"
              svg(
                xmlns: "http://www.w3.org/2000/svg",
                class: "h-6 w-6",
                fill: "none",
                viewBox: "0 0 24 24",
                stroke: "currentColor"
              ) do
                tag(:path,
                  stroke_linecap: "round",
                  stroke_linejoin: "round",
                  stroke_width: "2",
                  d: "M17 8l4 4m0 0l-4 4m4-4H3"
                )
              end
            end

            Link href: dashboard_path, class: "btn btn-lg bg-white/10 hover:bg-white/20 text-white border-white/30 backdrop-blur-sm gap-3 px-10" do
              svg(
                xmlns: "http://www.w3.org/2000/svg",
                class: "h-6 w-6",
                fill: "none",
                viewBox: "0 0 24 24",
                stroke: "currentColor"
              ) do
                tag(:path,
                  stroke_linecap: "round",
                  stroke_linejoin: "round",
                  stroke_width: "2",
                  d: "M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z"
                )
                tag(:path,
                  stroke_linecap: "round",
                  stroke_linejoin: "round",
                  stroke_width: "2",
                  d: "M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                )
              end
              plain "Смотреть демо"
            end
          end

          # Trust indicators
          div(class: "flex flex-wrap justify-center items-center gap-8 text-white/80 text-sm") do
            div(class: "flex items-center gap-2") do
              svg(xmlns: "http://www.w3.org/2000/svg", class: "h-5 w-5", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do
                tag(:path, stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M5 13l4 4L19 7")
              end
              plain "Без привязки карты"
            end
            div(class: "flex items-center gap-2") do
              svg(xmlns: "http://www.w3.org/2000/svg", class: "h-5 w-5", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do
                tag(:path, stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M5 13l4 4L19 7")
              end
              plain "30 дней бесплатно"
            end
            div(class: "flex items-center gap-2") do
              svg(xmlns: "http://www.w3.org/2000/svg", class: "h-5 w-5", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do
                tag(:path, stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M5 13l4 4L19 7")
              end
              plain "Отмена в любой момент"
            end
          end
        end
      end
    end

    def render_icon(type)
      case type
      when :lightning
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          class: "h-6 w-6",
          fill: "none",
          viewBox: "0 0 24 24",
          stroke: "currentColor"
        ) do
          tag(:path,
            stroke_linecap: "round",
            stroke_linejoin: "round",
            stroke_width: "2",
            d: "M13 10V3L4 14h7v7l9-11h-7z"
          )
        end
      when :grid
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          class: "h-6 w-6",
          fill: "none",
          viewBox: "0 0 24 24",
          stroke: "currentColor"
        ) do
          tag(:path,
            stroke_linecap: "round",
            stroke_linejoin: "round",
            stroke_width: "2",
            d: "M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"
          )
        end
      when :table
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          class: "h-6 w-6",
          fill: "none",
          viewBox: "0 0 24 24",
          stroke: "currentColor"
        ) do
          tag(:path,
            stroke_linecap: "round",
            stroke_linejoin: "round",
            stroke_width: "2",
            d: "M3 10h18M3 14h18m-9-4v8m-7 0h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"
          )
        end
      end
    end
  end
end
