# frozen_string_literal: true

module Landing
  class IndexView < ApplicationComponent
    def view_template
      div(class: "min-h-screen bg-base-100") do
        render_navigation
        render_hero_section
        render_features_section
        render_advantages_section
        render_architecture_section
        render_cta_section
        render_footer
      end
    end

    private

    def render_navigation
      nav(class: "navbar bg-base-100 shadow-sm border-b border-base-300") do
        div(class: "container mx-auto px-4") do
          div(class: "flex-1") do
            a(href: helpers.root_path, class: "text-2xl font-bold text-primary") { "A2D2" }
          end
          div(class: "flex-none") do
            ul(class: "menu menu-horizontal px-1 hidden md:flex") do
              li { a(href: "#features", class: "text-base-content/70 hover:text-primary") { "Возможности" } }
              li { a(href: "#advantages", class: "text-base-content/70 hover:text-primary") { "Преимущества" } }
              li { a(href: "#architecture", class: "text-base-content/70 hover:text-primary") { "Архитектура" } }
            end
            div(class: "ml-4 flex gap-2") do
              a(href: helpers.login_path, class: "btn btn-ghost") { "Вход" }
              a(href: helpers.signup_path, class: "btn btn-primary") { "Начать" }
            end
          end
        end
      end
    end

    def render_hero_section
      section(class: "py-20 bg-gradient-to-b from-base-100 to-base-200") do
        div(class: "container mx-auto px-4") do
          div(class: "max-w-4xl mx-auto text-center") do
            h1(class: "text-5xl md:text-6xl font-bold mb-6 text-base-content") do
              text "Управление интеллектуальными агентами "
              span(class: "text-primary") { "на платформе" }
            end
            p(class: "text-xl md:text-2xl mb-8 text-base-content/70") do
              text "Платформа A2D2, где интеллектуальные агенты управляют бизнес-процессами, а мета-система координирует их работу без участия человека"
            end
            div(class: "flex flex-wrap justify-center gap-4 mb-12") do
              a(href: helpers.signup_path, class: "btn btn-primary btn-lg gap-2") do
                svg_icon_flash
                text "Начать бесплатно"
              end
              a(href: helpers.dashboard_path, class: "btn btn-outline btn-lg gap-2") do
                svg_icon_play
                text "Смотреть демо"
              end
            end

            render_stats_cards
          end
        end
      end
    end

    def render_stats_cards
      div(class: "stats stats-vertical md:stats-horizontal shadow-lg bg-base-100 w-full max-w-3xl mx-auto") do
        div(class: "stat") do
          div(class: "stat-title") { "Агентов" }
          div(class: "stat-value text-primary") { "5+" }
          div(class: "stat-desc") { "специализированных типов" }
        end
        div(class: "stat") do
          div(class: "stat-title") { "LLM моделей" }
          div(class: "stat-value text-secondary") { "6+" }
          div(class: "stat-desc") { "через единый API" }
        end
        div(class: "stat") do
          div(class: "stat-title") { "Автоматизация" }
          div(class: "stat-value text-info") { "24/7" }
          div(class: "stat-desc") { "без участия человека" }
        end
      end
    end

    def render_features_section
      section(id: "features", class: "py-20 bg-base-100") do
        div(class: "container mx-auto px-4") do
          div(class: "text-center mb-16") do
            h2(class: "text-4xl font-bold mb-4 text-base-content") { "Ключевые возможности платформы" }
            p(class: "text-lg text-base-content/70 max-w-2xl mx-auto") do
              text "Уникальная архитектура с мета-слоем, который управляет"
            end
          end

          div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6") do
            render_feature_card("Автоматизация автоматизации", "Мета-слой, который управляет . Система сама оптимизирует процессы без участия человека.")
            render_feature_card("Единый API для LLM", "Поддержка: GPT, Claude, DeepSeek, Gemini, Grok, Mistral через один интерфейс. Переключайтесь без изменения кода.")
            render_feature_card("Интеллектуальные агенты", "Специализированные агенты для анализа, валидации, трансформации и интеграции систем.")
            render_feature_card("Самоорганизующаяся система", "Мониторинг, верификация действий, управление памятью и автоматическое восстановление.")
            render_feature_card("Готовые решения", "Модульная архитектура для быстрого старта от управления документами до корпоративных систем.")
            render_feature_card("Технологический суверенитет", "Российская разработка, независимая от санкций. Работа без VPN, оплата в рублях.")
          end
        end
      end
    end

    def render_feature_card(title, description)
      div(class: "card bg-base-100 shadow-lg border border-base-300 hover:shadow-xl transition-shadow") do
        div(class: "card-body") do
          div(class: "text-primary mb-4") do
            svg_icon_feature
          end
          h3(class: "card-title text-xl mb-2") { title }
          p(class: "text-base-content/70") { description }
        end
      end
    end

    def render_advantages_section
      section(id: "advantages", class: "py-20 bg-base-200") do
        div(class: "container mx-auto px-4") do
          div(class: "text-center mb-16") do
            h2(class: "text-4xl font-bold mb-4 text-base-content") { "Почему выбирают A2D2?" }
            p(class: "text-lg text-base-content/70 max-w-2xl mx-auto") do
              text "Конкурентные преимущества нашей платформы"
            end
          end

          div(class: "grid grid-cols-1 lg:grid-cols-2 gap-6 max-w-5xl mx-auto") do
            render_advantage_card("Единый API для LLM", "OpenAI-совместимый стандарт переключайтесь между моделями без изменения кода")
            render_advantage_card("Без VPN и блокировок", "Стабильная работа из России и СНГ без необходимости VPN")
            render_advantage_card("Оплата в рублях", "Удобная оплата банковской картой или криптовалютой")
            render_advantage_card("Умная маршрутизация", "Автоматическая оптимизация запросов для минимальной латентности и стоимости")
            render_advantage_card("Соответствие законам РФ", "Договоры и ЛД для ФЛ. Данные обрабатываются локально")
            render_advantage_card("Быстрая поддержка", "Техническая поддержка через GitHub Issues и Discussions")
          end
        end
      end
    end

    def render_advantage_card(title, description)
      div(class: "card bg-base-100 shadow-lg") do
        div(class: "card-body") do
          div(class: "flex items-start gap-4") do
            div(class: "badge badge-primary badge-lg p-4") do
              svg_icon_check
            end
            div do
              h3(class: "font-bold text-lg mb-2") { title }
              p(class: "text-base-content/70") { description }
            end
          end
        end
      end
    end

    def render_architecture_section
      section(id: "architecture", class: "py-20 bg-base-100") do
        div(class: "container mx-auto px-4") do
          div(class: "text-center mb-16") do
            h2(class: "text-4xl font-bold mb-4 text-base-content") { "Архитектура платформы" }
            p(class: "text-lg text-base-content/70 max-w-2xl mx-auto") do
              text "Многоуровневая система с мета-слоем оркестрации"
            end
          end

          div(class: "max-w-6xl mx-auto") do
            div(class: "tabs tabs-boxed justify-center mb-8") do
              a(class: "tab tab-active", data: { tab: "orchestration" }) { "Мета-слой" }
              a(class: "tab", data: { tab: "agents" }) { "Агенты" }
              a(class: "tab", data: { tab: "modules" }) { "Модули" }
            end

            div(id: "orchestration-content", class: "grid grid-cols-1 md:grid-cols-2 gap-4") do
              render_arch_card("Orchestrator", "Центральный координатор, управляющий жизненным циклом агентов и распределением задач")
              render_arch_card("Task Queue Manager", "Приоритизация и управление очередью задач на базе Solid Queue")
              render_arch_card("Agent Registry", "Реестр всех агентов с heartbeat-мониторингом и capability tracking")
              render_arch_card("Verification Layer", "Проверка качества работы агентов и автоматическое исправление ошибок")
              render_arch_card("Memory Management", "Управление контекстной памятью агентов на базе Solid Cache", true)
            end
          end
        end
      end
    end

    def render_arch_card(title, description, span_full = false)
      div(class: "card bg-base-200 shadow #{span_full ? 'md:col-span-2' : ''}") do
        div(class: "card-body") do
          h3(class: "card-title text-primary") { title }
          p(class: "text-sm text-base-content/70") { description }
        end
      end
    end

    def render_cta_section
      section(class: "py-20 bg-primary text-primary-content") do
        div(class: "container mx-auto px-4") do
          div(class: "max-w-3xl mx-auto text-center") do
            h2(class: "text-4xl font-bold mb-6") { "Готовы начать автоматизацию?" }
            p(class: "text-xl mb-8 opacity-90") do
              text "Присоединяйтесь к платформе A2D2 и получите доступ к интеллектуальным агентам"
            end
            div(class: "flex flex-wrap justify-center gap-4") do
              a(href: helpers.signup_path, class: "btn btn-lg bg-white text-primary hover:bg-base-100") do
                text "Создать аккаунт бесплатно"
              end
              a(href: helpers.dashboard_path, class: "btn btn-lg btn-outline border-white text-white hover:bg-white hover:text-primary") do
                text "Смотреть демо"
              end
            end
          end
        end
      end
    end

    def render_footer
      footer(class: "footer footer-center p-10 bg-base-200 text-base-content") do
        div do
          p(class: "font-bold text-lg") { "A2D2 - Automation to Automation Delivery" }
          p(class: "text-base-content/70") { "Платформа автоматизации автоматизации с интеллектуальными агентами" }
        end
        div do
          div(class: "grid grid-flow-col gap-4") do
            a(href: "https://github.com/unidel2035/a2d2", target: "_blank", rel: "noopener", class: "link link-hover") { "GitHub" }
            a(href: "https://github.com/unidel2035/a2d2/issues", target: "_blank", rel: "noopener", class: "link link-hover") { "Issues" }
            a(href: "https://github.com/unidel2035/a2d2/discussions", target: "_blank", rel: "noopener", class: "link link-hover") { "Discussions" }
            a(href: "#", class: "link link-hover") { "Документация" }
          end
        end
        div do
          p(class: "text-sm text-base-content/50") { "© 2025 A2D2. Разработано с 💙 в России. MIT License" }
        end
      end
    end

    def svg_icon_flash
      svg(xmlns: "http://www.w3.org/2000/svg", class: "h-6 w-6", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do |svg|
        svg.path(
          stroke_linecap: "round",
          stroke_linejoin: "round",
          stroke_width: "2",
          d: "M13 10V3L4 14h7v7l9-11h-7z"
        )
      end
    end

    def svg_icon_play
      svg(xmlns: "http://www.w3.org/2000/svg", class: "h-6 w-6", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do |svg|
        svg.path(
          stroke_linecap: "round",
          stroke_linejoin: "round",
          stroke_width: "2",
          d: "M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z"
        )
      end
    end

    def svg_icon_feature
      svg(xmlns: "http://www.w3.org/2000/svg", class: "h-12 w-12", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do |svg|
        svg.path(
          stroke_linecap: "round",
          stroke_linejoin: "round",
          stroke_width: "2",
          d: "M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z"
        )
      end
    end

    def svg_icon_check
      svg(xmlns: "http://www.w3.org/2000/svg", class: "h-6 w-6", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do |svg|
        svg.path(
          stroke_linecap: "round",
          stroke_linejoin: "round",
          stroke_width: "2",
          d: "M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
        )
      end
    end
  end
end
