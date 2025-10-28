# frozen_string_literal: true

module Home
  class IndexView < ApplicationComponent
    def initialize(logged_in: false, current_user: nil)
      @logged_in = logged_in
      @current_user = current_user
    end

    def template
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
      Hero class: "min-h-screen bg-gradient-to-br from-primary/10 via-secondary/10 to-accent/10" do |hero|
        hero.content class: "text-center" do
          div(class: "max-w-4xl") do
            h1(class: "text-6xl font-bold mb-6 bg-gradient-to-r from-primary via-secondary to-accent bg-clip-text text-transparent") do
              "A2D2"
            end

            p(class: "text-2xl font-semibold mb-4 text-base-content") do
              "Платформа автоматизации автоматизации"
            end

            p(class: "text-lg mb-8 text-base-content/70 max-w-2xl mx-auto leading-relaxed") do
              plain "Современная система на базе Ruby on Rails, где ИИ-агенты управляют "
              plain "бизнес-процессами, а мета-система координирует работу этих агентов"
            end

            div(class: "flex flex-wrap gap-4 justify-center") do
              Link href: signup_path, class: "btn btn-primary btn-lg gap-2" do
                render_icon(:lightning)
                plain "Начать работу"
              end

              Link href: components_path, class: "btn btn-outline btn-lg gap-2" do
                render_icon(:grid)
                plain "Компоненты дизайна"
              end

              Link href: spreadsheets_path, class: "btn btn-secondary btn-lg gap-2" do
                render_icon(:table)
                plain "Табличный редактор"
              end
            end
          end
        end
      end
    end

    def render_features_section
      div(id: "features", class: "py-20 bg-base-100") do
        div(class: "container mx-auto px-4") do
          h2(class: "text-4xl font-bold text-center mb-4") { "Основные возможности" }
          p(class: "text-center text-base-content/70 mb-12 max-w-2xl mx-auto") do
            "Полный набор инструментов для управления роботизацией и ИИ-агентами"
          end

          div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6") do
            render_feature_card("📋", "Управление документацией",
              "Централизованное хранение технических данных, конфигураций и инструкций по эксплуатации роботизированных систем")
            render_feature_card("📊", "Журналы операций",
              "Автоматическая регистрация заданий с данными телеметрии и контекстной информацией")
            render_feature_card("🔧", "Техническое обслуживание",
              "Планирование и учет регламентных работ, замены компонентов и ремонтов")
            render_feature_card("📸", "Инспекционные отчеты",
              "Создание фото и видео отчетов с привязкой к геолокации и объектам инспекции")
            render_feature_card("👥", "Управление операторами",
              "Учет операторов, их квалификаций, сертификатов и времени работы с системами")
            render_feature_card("📈", "Аналитика и отчеты",
              "Визуализация данных, статистика использования и автоматическая генерация отчетов")
          end
        end
      end
    end

    def render_feature_card(emoji, title, description)
      Card :base_200, class: "hover:shadow-xl transition-all duration-300 hover:-translate-y-2" do |card|
        card.body do
          div(class: "text-5xl mb-4") { emoji }
          card.title(class: "text-xl") { title }
          p(class: "text-base-content/70") { description }
        end
      end
    end

    def render_about_section
      div(id: "about", class: "py-20 bg-base-200") do
        div(class: "container mx-auto px-4") do
          div(class: "max-w-4xl mx-auto text-center") do
            h2(class: "text-4xl font-bold mb-6") { "О проекте" }
            p(class: "text-lg text-base-content/80 mb-8 leading-relaxed") do
              plain "A2D2 - это платформа автоматизации автоматизации для организаций, внедряющих роботизацию "
              plain "и ИИ-агенты. Система обеспечивает управление интеллектуальными агентами, "
              plain "упрощает документооборот и автоматизирует бизнес-процессы."
            end

            div(class: "grid grid-cols-1 md:grid-cols-3 gap-8 mt-12") do
              render_stat("100%", "Соответствие ГОСТ", :primary)
              render_stat("24/7", "Доступность", :secondary)
              render_stat("Secure", "Безопасность данных", :accent)
            end
          end
        end
      end
    end

    def render_stat(value, title, color)
      Stat class: "bg-base-100 rounded-box shadow-lg" do |stat|
        stat.value(class: "text-#{color}") { value }
        stat.title { title }
      end
    end

    def render_cta_section
      div(class: "py-20 bg-gradient-to-r from-primary to-secondary") do
        div(class: "container mx-auto px-4 text-center") do
          h2(class: "text-4xl font-bold text-white mb-6") { "Готовы начать?" }
          p(class: "text-xl text-white/90 mb-8 max-w-2xl mx-auto") do
            "Присоединяйтесь к A2D2 и начните автоматизировать вашу автоматизацию уже сегодня"
          end

          Link href: signup_path, class: "btn btn-lg bg-white text-primary hover:bg-base-100 border-0" do
            plain "Создать аккаунт бесплатно"
            svg(
              xmlns: "http://www.w3.org/2000/svg",
              class: "h-6 w-6",
              fill: "none",
              viewBox: "0 0 24 24",
              stroke: "currentColor"
            ) do
              path(
                stroke_linecap: "round",
                stroke_linejoin: "round",
                stroke_width: "2",
                d: "M17 8l4 4m0 0l-4 4m4-4H3"
              )
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
          path(
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
          path(
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
          path(
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
