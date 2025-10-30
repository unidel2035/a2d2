# frozen_string_literal: true

module Landing
  class IndexView < ApplicationComponent
    def view_template
      div(class: "min-h-screen") do
        render_hero_section
        render_key_features
        render_tech_stack
        render_quick_start
        render_footer
      end
    end

    private

    def render_hero_section
      section(class: "hero min-h-screen bg-gradient-to-br from-primary/10 via-secondary/10 to-accent/10") do
        div(class: "hero-content text-center") do
          div(class: "max-w-4xl") do
            # Badge
            div(class: "mb-6") do
              Badge :primary, class: "badge-lg gap-2" do
                plain "🚀"
                plain "Automation to Automation Delivery"
              end
            end

            # Main heading
            h1(class: "text-5xl md:text-6xl lg:text-7xl font-bold mb-6 bg-gradient-to-r from-primary via-secondary to-accent bg-clip-text text-transparent") do
              plain "A2D2"
            end

            h2(class: "text-3xl md:text-4xl font-bold mb-8 text-base-content") do
              plain "Платформа автоматизации автоматизации с интеллектуальными агентами"
            end

            # Description
            p(class: "text-xl md:text-2xl mb-8 text-base-content/80 leading-relaxed") do
              plain "Платформа «Автоматизации автоматизации» на базе Ruby on Rails, где ИИ-агенты управляют бизнес-процессами, а мета-система координирует работу этих агентов. Экосистема интеллектуальных агентов, которые автономно выполняют задачи, взаимодействуют друг с другом и непрерывно обучаются."
            end

            # CTA Buttons
            div(class: "flex flex-wrap gap-4 justify-center mb-12") do
              a(
                href: "https://github.com/unidel2035/a2d2",
                target: "_blank",
                rel: "noopener noreferrer",
                class: "btn btn-primary btn-lg gap-2"
              ) do
                render_github_icon
                plain "GitHub"
              end

              a(
                href: "#features",
                class: "btn btn-secondary btn-lg gap-2"
              ) do
                plain "Узнать больше"
              end
            end

            # Stats
            div(class: "stats stats-vertical lg:stats-horizontal shadow-2xl bg-base-100") do
              div(class: "stat place-items-center") do
                div(class: "stat-title") { "Ruby on Rails" }
                div(class: "stat-value text-primary") { "8.1" }
                div(class: "stat-desc") { "Современный стек" }
              end

              div(class: "stat place-items-center") do
                div(class: "stat-title") { "Open Source" }
                div(class: "stat-value text-secondary") { "MIT" }
                div(class: "stat-desc") { "Свободная лицензия" }
              end

              div(class: "stat place-items-center") do
                div(class: "stat-title") { "Сделано в" }
                div(class: "stat-value text-accent") { "🇷🇺" }
                div(class: "stat-desc") { "России" }
              end
            end
          end
        end
      end
    end

    def render_key_features
      section(id: "features", class: "py-20 bg-base-100") do
        div(class: "container mx-auto px-4") do
          # Section header
          div(class: "text-center mb-16") do
            h2(class: "text-4xl md:text-5xl font-bold mb-4") { "Ключевые преимущества платформы" }
            p(class: "text-xl text-base-content/70") do
              plain "Уникальная архитектура с мета-слоем, где ИИ управляет ИИ"
            end
          end

          # Features grid
          div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8") do
            render_feature_card(
              "🤖 Автоматизация автоматизации",
              "Уникальная архитектура с мета-слоем, где ИИ управляет ИИ. Интеллектуальные агенты автономно выполняют бизнес-процессы, а оркестратор координирует их работу, распределяет задачи и обеспечивает качество результатов.",
              "primary"
            )

            render_feature_card(
              "🔌 Единый API для всех LLM",
              "Получайте доступ к GPT, Claude, DeepSeek, Gemini, Grok, Mistral через единый интерфейс. OpenAI-совместимый стандарт для простой миграции, умная маршрутизация запросов для оптимизации скорости и стоимости.",
              "secondary"
            )

            render_feature_card(
              "🧠 Интеллектуальные агенты",
              "Специализированные ИИ-агенты для различных задач — анализ данных, валидация, трансформация, генерация отчетов и интеграция систем. Каждый агент обладает контекстной памятью и способностью к обучению.",
              "accent"
            )

            render_feature_card(
              "🔄 Самоорганизующаяся экосистема",
              "Мета-слой непрерывно мониторит работу агентов, верифицирует их действия, управляет памятью и потоками данных. При возникновении проблем система автоматически адаптирует стратегии и восстанавливает работоспособность.",
              "info"
            )

            render_feature_card(
              "📦 Готовые решения из коробки",
              "Модульная архитектура для быстрого старта — от управления документами и аналитики до корпоративных систем и интеграций. Каждый модуль интегрирован с агентной инфраструктурой и готов к масштабированию.",
              "success"
            )

            render_feature_card(
              "🛡️ Технологический суверенитет",
              "Российская разработка, независимая от иностранного ПО. Стабильный доступ без VPN из России и СНГ. Оплата в рублях или криптовалюте. Все данные защищены сквозным шифрованием с полным контролем над инфраструктурой.",
              "warning"
            )
          end
        end
      end
    end

    def render_feature_card(title, description, color)
      Card responsive: true, class: "shadow-xl hover:shadow-2xl transition-all duration-300 border-2 border-transparent hover:border-#{color}" do
        div(class: "card-body") do
          h3(class: "card-title text-2xl mb-4 text-#{color}") { title }
          p(class: "text-base-content/80 leading-relaxed text-lg") { description }
        end
      end
    end

    def render_tech_stack
      section(class: "py-20 bg-base-200") do
        div(class: "container mx-auto px-4") do
          # Section header
          div(class: "text-center mb-16") do
            h2(class: "text-4xl md:text-5xl font-bold mb-4") { "Современный технологический стек" }
            p(class: "text-xl text-base-content/70") do
              plain "Production-ready решение на проверенных технологиях"
            end
          end

          # Tech categories
          div(class: "grid grid-cols-1 lg:grid-cols-3 gap-8") do
            # Backend
            Card responsive: true, class: "shadow-xl" do
              div(class: "card-body") do
                h3(class: "card-title text-2xl mb-4 text-primary") do
                  plain "🔧 Backend"
                end
                ul(class: "space-y-2 text-base-content/80") do
                  li { plain "Ruby 3.3.6" }
                  li { plain "Rails 8.1.0" }
                  li { plain "Puma 7.1.0" }
                  li { plain "Solid Queue" }
                  li { plain "Solid Cache" }
                  li { plain "Solid Cable" }
                  li { plain "PostgreSQL / SQLite" }
                end
              end
            end

            # Frontend
            Card responsive: true, class: "shadow-xl" do
              div(class: "card-body") do
                h3(class: "card-title text-2xl mb-4 text-secondary") do
                  plain "🎨 Frontend"
                end
                ul(class: "space-y-2 text-base-content/80") do
                  li { plain "Phlex (Ruby DSL для HTML)" }
                  li { plain "PhlexyUI (DaisyUI компоненты)" }
                  li { plain "Turbo (SPA-подобное ускорение)" }
                  li { plain "Stimulus (JS фреймворк)" }
                  li { plain "Importmap Rails" }
                  li { plain "Tailwind CSS / DaisyUI" }
                end
              end
            end

            # AI & Security
            Card responsive: true, class: "shadow-xl" do
              div(class: "card-body") do
                h3(class: "card-title text-2xl mb-4 text-accent") do
                  plain "🔐 AI & Security"
                end
                ul(class: "space-y-2 text-base-content/80") do
                  li { plain "OpenAI API" }
                  li { plain "Anthropic Claude API" }
                  li { plain "Devise (Authentication)" }
                  li { plain "Pundit (Authorization)" }
                  li { plain "JWT Tokens" }
                  li { plain "Rack Attack" }
                  li { plain "Secure Headers" }
                end
              end
            end
          end
        end
      end
    end

    def render_quick_start
      section(class: "py-20 bg-base-100") do
        div(class: "container mx-auto px-4") do
          # Section header
          div(class: "text-center mb-16") do
            h2(class: "text-4xl md:text-5xl font-bold mb-4") { "Быстрый старт" }
            p(class: "text-xl text-base-content/70") do
              plain "Начните работу за несколько минут"
            end
          end

          # Steps
          div(class: "max-w-4xl mx-auto") do
            div(class: "grid grid-cols-1 md:grid-cols-2 gap-8") do
              # Step 1
              Card responsive: true, class: "shadow-xl bg-primary/5" do
                div(class: "card-body") do
                  Badge :primary, class: "mb-4 badge-lg" do
                    plain "Шаг 1"
                  end
                  h3(class: "card-title text-xl mb-3") { "Клонируйте репозиторий" }
                  div(class: "mockup-code text-sm") do
                    pre(data: { prefix: "$" }) do
                      code { "git clone https://github.com/unidel2035/a2d2.git" }
                    end
                    pre(data: { prefix: "$" }) do
                      code { "cd a2d2" }
                    end
                  end
                end
              end

              # Step 2
              Card responsive: true, class: "shadow-xl bg-secondary/5" do
                div(class: "card-body") do
                  Badge :secondary, class: "mb-4 badge-lg" do
                    plain "Шаг 2"
                  end
                  h3(class: "card-title text-xl mb-3") { "Установите зависимости" }
                  div(class: "mockup-code text-sm") do
                    pre(data: { prefix: "$" }) do
                      code { "bundle install" }
                    end
                    pre(data: { prefix: "$" }) do
                      code { "bin/rails db:setup" }
                    end
                  end
                end
              end

              # Step 3
              Card responsive: true, class: "shadow-xl bg-accent/5" do
                div(class: "card-body") do
                  Badge :accent, class: "mb-4 badge-lg" do
                    plain "Шаг 3"
                  end
                  h3(class: "card-title text-xl mb-3") { "Запустите сервер" }
                  div(class: "mockup-code text-sm") do
                    pre(data: { prefix: "$" }) do
                      code { "bin/dev" }
                    end
                  end
                  p(class: "text-sm text-base-content/60 mt-2") do
                    plain "Откройте "
                    code(class: "text-accent") { "http://localhost:3000" }
                  end
                end
              end

              # Step 4
              Card responsive: true, class: "shadow-xl bg-success/5" do
                div(class: "card-body") do
                  Badge :success, class: "mb-4 badge-lg" do
                    plain "Шаг 4"
                  end
                  h3(class: "card-title text-xl mb-3") { "Готово! 🎉" }
                  p(class: "text-base-content/80") do
                    plain "Платформа запущена и готова к работе. Изучите документацию на GitHub для настройки ИИ-агентов и интеграций."
                  end
                end
              end
            end
          end

          # System requirements
          div(class: "mt-16 max-w-3xl mx-auto") do
            div(class: "alert alert-info shadow-lg") do
              div do
                svg(
                  xmlns: "http://www.w3.org/2000/svg",
                  fill: "none",
                  viewBox: "0 0 24 24",
                  class: "stroke-current flex-shrink-0 w-6 h-6"
                ) do |s|
                  s.path(
                    stroke_linecap: "round",
                    stroke_linejoin: "round",
                    stroke_width: "2",
                    d: "M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                  )
                end
                div do
                  h3(class: "font-bold") { "Системные требования" }
                  div(class: "text-sm") do
                    plain "Ruby 3.3.6+, Rails 8.1.0, Node.js 18+, SQLite3 (для разработки)"
                  end
                end
              end
            end
          end
        end
      end
    end

    def render_footer
      footer(class: "footer footer-center p-10 bg-base-200 text-base-content") do
        div do
          div(class: "mb-4") do
            h3(class: "text-3xl font-bold bg-gradient-to-r from-primary via-secondary to-accent bg-clip-text text-transparent") do
              plain "A2D2"
            end
          end

          p(class: "font-semibold text-lg") do
            plain "Automation to Automation Delivery"
          end

          p(class: "text-base-content/70 max-w-2xl") do
            plain "Платформа автоматизации автоматизации с интеллектуальными агентами. Первая российская разработка с архитектурой «ИИ управляет ИИ»."
          end
        end

        div do
          div(class: "grid grid-flow-col gap-6") do
            a(
              href: "https://github.com/unidel2035/a2d2",
              target: "_blank",
              rel: "noopener noreferrer",
              class: "link link-hover text-lg"
            ) { "GitHub" }

            a(
              href: "https://github.com/unidel2035/a2d2#readme",
              target: "_blank",
              rel: "noopener noreferrer",
              class: "link link-hover text-lg"
            ) { "Документация" }

            a(
              href: "https://github.com/unidel2035/a2d2/issues",
              target: "_blank",
              rel: "noopener noreferrer",
              class: "link link-hover text-lg"
            ) { "Issues" }

            a(
              href: "https://github.com/unidel2035/a2d2/discussions",
              target: "_blank",
              rel: "noopener noreferrer",
              class: "link link-hover text-lg"
            ) { "Discussions" }
          end
        end

        div do
          div(class: "grid grid-flow-col gap-4") do
            a(
              href: "https://github.com/unidel2035/a2d2",
              target: "_blank",
              rel: "noopener noreferrer",
              class: "btn btn-ghost btn-circle",
              aria: { label: "GitHub" }
            ) do
              render_github_icon
            end
          end
        end

        div do
          p(class: "text-base-content/60") do
            plain "© 2025 A2D2. Разработано с 🇷🇺 в России"
          end
          p(class: "text-sm text-base-content/50") do
            plain "MIT License • Ruby on Rails 8.1 • Open Source"
          end
        end
      end
    end

    # Helper methods
    def render_github_icon
      svg(
        xmlns: "http://www.w3.org/2000/svg",
        class: "h-6 w-6",
        fill: "currentColor",
        viewBox: "0 0 24 24"
      ) do |s|
        s.path(
          d: "M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"
        )
      end
    end
  end
end
