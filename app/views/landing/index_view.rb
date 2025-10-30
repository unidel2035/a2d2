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
        render_use_cases_section
        render_cta_section
        render_footer
      end
    end

    private

    def render_navigation
      nav(class: "navbar bg-base-100 shadow-sm border-b border-base-300 sticky top-0 z-50") do
        div(class: "container mx-auto px-4") do
          div(class: "flex-1") do
            a(href: helpers.root_path, class: "text-2xl font-bold text-primary flex items-center gap-2") do
              span(class: "text-3xl") { "🤖" }
              text "A2D2"
            end
          end
          div(class: "flex-none") do
            ul(class: "menu menu-horizontal px-1 hidden md:flex") do
              li { a(href: "#features", class: "text-base-content/70 hover:text-primary") { "Возможности" } }
              li { a(href: "#advantages", class: "text-base-content/70 hover:text-primary") { "Преимущества" } }
              li { a(href: "#architecture", class: "text-base-content/70 hover:text-primary") { "Архитектура" } }
              li { a(href: "#cases", class: "text-base-content/70 hover:text-primary") { "Кейсы" } }
            end
            div(class: "ml-4 flex gap-2") do
              a(href: "https://github.com/unidel2035/a2d2", target: "_blank", rel: "noopener", class: "btn btn-ghost btn-sm") do
                svg_github_icon
                span(class: "hidden sm:inline") { "GitHub" }
              end
              if defined?(helpers.new_user_session_path)
                a(href: helpers.new_user_session_path, class: "btn btn-ghost btn-sm") { "Вход" }
                a(href: helpers.new_user_registration_path, class: "btn btn-primary btn-sm") { "Начать" }
              end
            end
          end
        end
      end
    end

    def render_hero_section
      section(class: "py-20 bg-gradient-to-b from-base-100 to-base-200") do
        div(class: "container mx-auto px-4") do
          div(class: "max-w-5xl mx-auto text-center") do
            # Бейдж с версией
            div(class: "mb-6") do
              span(class: "badge badge-primary badge-lg gap-2") do
                svg_sparkles_icon
                text "Платформа автоматизации автоматизации"
              end
            end

            # Основной заголовок
            h1(class: "text-5xl md:text-6xl lg:text-7xl font-bold mb-6 text-base-content leading-tight") do
              text "Автоматизация "
              br(class: "hidden md:block")
              span(class: "text-primary") { "автоматизации" }
              text " с ИИ-агентами"
            end

            # Подзаголовок
            p(class: "text-xl md:text-2xl mb-8 text-base-content/70 max-w-3xl mx-auto") do
              text "Первая российская платформа с архитектурой «ИИ управляет ИИ», где интеллектуальные агенты работают 24/7, а мета-система координирует их работу без участия человека"
            end

            # Кнопки действий
            div(class: "flex flex-wrap justify-center gap-4 mb-12") do
              a(href: "https://github.com/unidel2035/a2d2", target: "_blank", rel: "noopener", class: "btn btn-primary btn-lg gap-2") do
                svg_rocket_icon
                text "Начать бесплатно"
              end
              a(href: "#features", class: "btn btn-outline btn-lg gap-2") do
                svg_play_icon
                text "Узнать больше"
              end
            end

            # Статистика
            render_stats_cards
          end
        end
      end
    end

    def render_stats_cards
      div(class: "stats stats-vertical md:stats-horizontal shadow-xl bg-base-100 w-full max-w-4xl mx-auto") do
        div(class: "stat place-items-center") do
          div(class: "stat-figure text-primary") do
            svg_cpu_icon
          end
          div(class: "stat-title") { "Типов агентов" }
          div(class: "stat-value text-primary") { "5+" }
          div(class: "stat-desc") { "Специализированных ИИ-агентов" }
        end

        div(class: "stat place-items-center") do
          div(class: "stat-figure text-secondary") do
            svg_brain_icon
          end
          div(class: "stat-title") { "LLM моделей" }
          div(class: "stat-value text-secondary") { "6+" }
          div(class: "stat-desc") { "Через единый API" }
        end

        div(class: "stat place-items-center") do
          div(class: "stat-figure text-info") do
            svg_clock_icon
          end
          div(class: "stat-title") { "Автоматизация" }
          div(class: "stat-value text-info") { "24/7" }
          div(class: "stat-desc") { "Без участия человека" }
        end
      end
    end

    def render_features_section
      section(id: "features", class: "py-20 bg-base-100") do
        div(class: "container mx-auto px-4") do
          # Заголовок секции
          div(class: "text-center mb-16") do
            h2(class: "text-4xl md:text-5xl font-bold mb-4 text-base-content") { "Ключевые возможности" }
            p(class: "text-lg md:text-xl text-base-content/70 max-w-3xl mx-auto") do
              text "Уникальная архитектура с мета-слоем оркестрации, где ИИ управляет ИИ"
            end
          end

          # Сетка карточек возможностей
          div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6") do
            render_feature_card(
              "🎯 Автоматизация автоматизации",
              "Мета-слой управляет интеллектуальными агентами. Оркестратор распределяет задачи, верифицирует результаты и оптимизирует процессы автоматически.",
              "primary"
            )

            render_feature_card(
              "🔌 Единый API для LLM",
              "Доступ к GPT, Claude, DeepSeek, Gemini, Grok, Mistral через один интерфейс. OpenAI-совместимый стандарт для простой миграции.",
              "secondary"
            )

            render_feature_card(
              "🧠 Интеллектуальные агенты",
              "Специализированные агенты для анализа, валидации, трансформации, отчетности и интеграции. Каждый обладает контекстной памятью.",
              "accent"
            )

            render_feature_card(
              "🔄 Самоорганизующаяся система",
              "Непрерывный мониторинг, верификация действий, управление памятью и автоматическое восстановление при сбоях.",
              "info"
            )

            render_feature_card(
              "📦 Готовые решения",
              "Модульная архитектура для быстрого старта: документы, процессы, аналитика, интеграции. Всё готово к масштабированию.",
              "success"
            )

            render_feature_card(
              "🛡️ Технологический суверенитет",
              "Российская разработка, независимая от санкций. Работа без VPN, оплата в рублях. Полный контроль над данными.",
              "warning"
            )
          end
        end
      end
    end

    def render_feature_card(title, description, color = "primary")
      div(class: "card bg-base-100 shadow-xl border border-base-300 hover:shadow-2xl hover:border-#{color} transition-all duration-300 group") do
        div(class: "card-body") do
          h3(class: "card-title text-xl mb-3 group-hover:text-#{color} transition-colors") { title }
          p(class: "text-base-content/70 leading-relaxed") { description }
        end
      end
    end

    def render_advantages_section
      section(id: "advantages", class: "py-20 bg-base-200") do
        div(class: "container mx-auto px-4") do
          # Заголовок секции
          div(class: "text-center mb-16") do
            h2(class: "text-4xl md:text-5xl font-bold mb-4 text-base-content") { "Почему выбирают A2D2?" }
            p(class: "text-lg md:text-xl text-base-content/70 max-w-3xl mx-auto") do
              text "Конкурентные преимущества на стыке агентных ИИ-систем и технологического суверенитета"
            end
          end

          # Сетка преимуществ
          div(class: "grid grid-cols-1 lg:grid-cols-2 gap-6 max-w-6xl mx-auto") do
            render_advantage_card(
              "🔌 Единый API для всех LLM",
              "OpenAI-совместимый стандарт для доступа к GPT, Claude, DeepSeek, Gemini, Grok, Mistral. Переключайтесь между моделями без изменения кода.",
              "primary"
            )

            render_advantage_card(
              "🌐 Без VPN и блокировок",
              "Стабильная работа из России и СНГ без VPN. Независимость от санкций и блокировок иностранных сервисов.",
              "secondary"
            )

            render_advantage_card(
              "💰 Оплата в рублях и криптовалюте",
              "Удобная оплата российской банковской картой в рублях или криптовалютой. Никаких валютных ограничений.",
              "accent"
            )

            render_advantage_card(
              "⚡ Умная маршрутизация запросов",
              "Автоматическая оптимизация маршрутов для минимальной латентности и стоимости. Выбор лучшей модели для задачи.",
              "info"
            )

            render_advantage_card(
              "🛡️ Соответствие законам РФ",
              "Работа по российскому законодательству, договоры и ЭДО для юр. лиц. Данные обрабатываются локально.",
              "success"
            )

            render_advantage_card(
              "🤝 Быстрая техническая поддержка",
              "Поддержка через GitHub Issues и Discussions на русском языке. Быстрые ответы и помощь в интеграции.",
              "warning"
            )
          end
        end
      end
    end

    def render_advantage_card(title, description, color = "primary")
      div(class: "card bg-base-100 shadow-xl hover:shadow-2xl transition-all duration-300") do
        div(class: "card-body") do
          div(class: "flex items-start gap-4") do
            div(class: "flex-shrink-0") do
              div(class: "w-12 h-12 rounded-lg bg-#{color}/10 flex items-center justify-center") do
                svg_check_circle_icon(color)
              end
            end
            div(class: "flex-1") do
              h3(class: "font-bold text-lg mb-2 text-#{color}") { title }
              p(class: "text-base-content/70 leading-relaxed") { description }
            end
          end
        end
      end
    end

    def render_architecture_section
      section(id: "architecture", class: "py-20 bg-base-100") do
        div(class: "container mx-auto px-4") do
          # Заголовок секции
          div(class: "text-center mb-16") do
            h2(class: "text-4xl md:text-5xl font-bold mb-4 text-base-content") { "Архитектура платформы" }
            p(class: "text-lg md:text-xl text-base-content/70 max-w-3xl mx-auto") do
              text "Трёхуровневая система: мета-слой оркестрации, интеллектуальные агенты, готовые модули"
            end
          end

          # Мета-слой оркестрации
          div(class: "mb-12") do
            div(class: "text-center mb-8") do
              h3(class: "text-3xl font-bold text-primary mb-2") { "Мета-слой: Оркестрация ИИ-агентов" }
              p(class: "text-base-content/60") { "Центральная система управления агентами" }
            end

            div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 max-w-6xl mx-auto") do
              render_arch_card(
                "🎯 Orchestrator",
                "Центральный координатор, управляющий жизненным циклом агентов и распределением задач",
                "primary"
              )
              render_arch_card(
                "📋 Task Queue Manager",
                "Приоритизация и управление очередью задач на базе Solid Queue с retry-логикой",
                "secondary"
              )
              render_arch_card(
                "🔍 Agent Registry",
                "Реестр агентов с heartbeat-мониторингом и capability tracking",
                "accent"
              )
              render_arch_card(
                "🧪 Verification Layer",
                "Проверка качества работы агентов и автоматическое исправление ошибок",
                "info"
              )
              render_arch_card(
                "💾 Memory Management",
                "Управление контекстной памятью агентов на базе Solid Cache",
                "success"
              )
            end
          end

          # Слой агентов
          div(class: "mb-12") do
            div(class: "text-center mb-8") do
              h3(class: "text-3xl font-bold text-secondary mb-2") { "Слой интеллектуальных агентов" }
              p(class: "text-base-content/60") { "Специализированные ИИ-агенты для различных задач" }
            end

            div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 max-w-6xl mx-auto") do
              render_agent_card("📊 Analyzer Agent", "Анализ данных, статистика, детекция аномалий")
              render_agent_card("🔄 Transformer Agent", "Трансформация и очистка данных, конвертация форматов")
              render_agent_card("✅ Validator Agent", "Валидация данных по бизнес-правилам и форматам")
              render_agent_card("📑 Reporter Agent", "Генерация отчетов в PDF/Excel с визуализацией")
              render_agent_card("🔌 Integration Agent", "Интеграция с внешними системами и API")
            end
          end

          # Модули
          div do
            div(class: "text-center mb-8") do
              h3(class: "text-3xl font-bold text-accent mb-2") { "Готовые модули платформы" }
              p(class: "text-base-content/60") { "Быстрый старт с готовыми решениями" }
            end

            div(class: "grid grid-cols-1 md:grid-cols-2 gap-4 max-w-4xl mx-auto") do
              render_module_card("📄 Управление документами", "Автоматическая обработка и классификация документов")
              render_module_card("🔄 Процессная автоматизация", "Визуальный конструктор бизнес-процессов")
              render_module_card("📊 Аналитика и отчетность", "Интеллектуальный анализ данных и инсайты")
              render_module_card("🔌 Интеграционная шина", "Подключение к ERP, CRM, 1C и другим системам")
            end
          end
        end
      end
    end

    def render_arch_card(title, description, color = "primary")
      div(class: "card bg-base-200 shadow-lg hover:shadow-xl transition-all duration-300 border-l-4 border-#{color}") do
        div(class: "card-body p-4") do
          h4(class: "font-bold text-#{color} mb-2") { title }
          p(class: "text-sm text-base-content/70") { description }
        end
      end
    end

    def render_agent_card(title, description)
      div(class: "card bg-base-100 shadow-lg hover:shadow-xl transition-all duration-300 border border-secondary/20") do
        div(class: "card-body p-4") do
          h4(class: "font-bold text-secondary mb-2") { title }
          p(class: "text-sm text-base-content/70") { description }
        end
      end
    end

    def render_module_card(title, description)
      div(class: "card bg-base-100 shadow-lg hover:shadow-xl transition-all duration-300 border border-accent/20") do
        div(class: "card-body") do
          h4(class: "font-bold text-accent text-lg mb-2") { title }
          p(class: "text-base-content/70") { description }
        end
      end
    end

    def render_use_cases_section
      section(id: "cases", class: "py-20 bg-base-200") do
        div(class: "container mx-auto px-4") do
          # Заголовок секции
          div(class: "text-center mb-16") do
            h2(class: "text-4xl md:text-5xl font-bold mb-4 text-base-content") { "Реальные кейсы внедрения" }
            p(class: "text-lg md:text-xl text-base-content/70 max-w-3xl mx-auto") do
              text "Как компании используют A2D2 для автоматизации бизнес-процессов"
            end
          end

          # Кейсы
          div(class: "grid grid-cols-1 lg:grid-cols-2 gap-8 max-w-6xl mx-auto") do
            render_case_card(
              "🚚 Логистическая компания",
              "500+ сотрудников",
              "Автоматизация обработки 3000 заявок в день",
              [
                "Время обработки: 15 мин → 2 мин",
                "Освобождено 60% времени менеджеров",
                "Ошибки снижены с 8% до 0.5%",
                "ROI за 5 месяцев"
              ],
              "2,400,000 руб/год"
            )

            render_case_card(
              "🏥 Страховая компания",
              "200 сотрудников",
              "Обработка страховых случаев с проверкой документов",
              [
                "Время обработки: 5-7 дней → 4-6 часов",
                "Пропускная способность × 4",
                "Выявление мошенничества +35%",
                "NPS клиентов +28 пунктов"
              ],
              "3,600,000 руб/год"
            )

            render_case_card(
              "🏭 Производственная компания",
              "1000+ сотрудников",
              "Интеграция разрозненных систем ERP, MES, WMS, CRM",
              [
                "Время формирования отчета: 3 дня → 10 минут",
                "Устранено дублирование данных",
                "Метрики в реальном времени",
                "Ошибки синхронизации = 0"
              ],
              "5,000,000 руб/год"
            )

            render_case_card(
              "💻 Системный интегратор",
              "50 сотрудников",
              "Использование A2D2 как платформы для проектов",
              [
                "Время внедрения: 6-8 мес → 3-6 недель",
                "Стоимость проектов -60%",
                "Количество проектов: 5 → 15",
                "Выручка компании × 2.5"
              ],
              "+18,000,000 руб/год"
            )
          end
        end
      end
    end

    def render_case_card(title, subtitle, description, results, savings)
      div(class: "card bg-base-100 shadow-xl hover:shadow-2xl transition-all duration-300") do
        div(class: "card-body") do
          h3(class: "card-title text-2xl mb-2") { title }
          div(class: "badge badge-primary mb-4") { subtitle }
          p(class: "text-base-content/80 mb-4 font-medium") { description }

          div(class: "space-y-2 mb-4") do
            results.each do |result|
              div(class: "flex items-start gap-2") do
                span(class: "text-success text-lg") { "✓" }
                span(class: "text-base-content/70") { result }
              end
            end
          end

          div(class: "divider") end

          div(class: "flex items-center justify-between") do
            span(class: "text-sm text-base-content/60") { "Экономия:" }
            span(class: "text-xl font-bold text-success") { savings }
          end
        end
      end
    end

    def render_cta_section
      section(class: "py-20 bg-gradient-to-br from-primary to-secondary text-primary-content") do
        div(class: "container mx-auto px-4") do
          div(class: "max-w-4xl mx-auto text-center") do
            h2(class: "text-4xl md:text-5xl font-bold mb-6") { "Готовы начать автоматизацию?" }
            p(class: "text-xl md:text-2xl mb-8 opacity-90 max-w-2xl mx-auto") do
              text "Присоединяйтесь к платформе A2D2 и получите доступ к интеллектуальным агентам для автоматизации ваших бизнес-процессов"
            end

            div(class: "flex flex-wrap justify-center gap-4 mb-8") do
              a(
                href: "https://github.com/unidel2035/a2d2",
                target: "_blank",
                rel: "noopener",
                class: "btn btn-lg bg-white text-primary hover:bg-base-100 border-none gap-2"
              ) do
                svg_github_icon
                text "Открыть на GitHub"
              end

              a(
                href: "https://github.com/unidel2035/a2d2/discussions",
                target: "_blank",
                rel: "noopener",
                class: "btn btn-lg btn-outline border-white text-white hover:bg-white hover:text-primary gap-2"
              ) do
                svg_chat_icon
                text "Обсудить проект"
              end
            end

            div(class: "flex flex-wrap justify-center gap-6 text-sm opacity-80") do
              div(class: "flex items-center gap-2") do
                span { "✓" }
                text "MIT License"
              end
              div(class: "flex items-center gap-2") do
                span { "✓" }
                text "Open Source"
              end
              div(class: "flex items-center gap-2") do
                span { "✓" }
                text "Бесплатно"
              end
              div(class: "flex items-center gap-2") do
                span { "✓" }
                text "Российская разработка"
              end
            end
          end
        end
      end
    end

    def render_footer
      footer(class: "footer footer-center p-10 bg-base-200 text-base-content") do
        div do
          div(class: "flex items-center gap-2 mb-2") do
            span(class: "text-3xl") { "🤖" }
            p(class: "font-bold text-xl") { "A2D2" }
          end
          p(class: "font-semibold") { "Automation to Automation Delivery" }
          p(class: "text-base-content/70 max-w-md") do
            text "Платформа автоматизации автоматизации с интеллектуальными агентами. Первая российская разработка с архитектурой «ИИ управляет ИИ»"
          end
        end

        div(class: "grid grid-flow-col gap-4") do
          a(
            href: "https://github.com/unidel2035/a2d2",
            target: "_blank",
            rel: "noopener",
            class: "link link-hover",
            aria: { label: "GitHub репозиторий" }
          ) { "GitHub" }
          a(
            href: "https://github.com/unidel2035/a2d2/issues",
            target: "_blank",
            rel: "noopener",
            class: "link link-hover"
          ) { "Issues" }
          a(
            href: "https://github.com/unidel2035/a2d2/discussions",
            target: "_blank",
            rel: "noopener",
            class: "link link-hover"
          ) { "Discussions" }
          a(
            href: "https://github.com/unidel2035/a2d2#readme",
            target: "_blank",
            rel: "noopener",
            class: "link link-hover"
          ) { "Документация" }
        end

        div(class: "grid grid-flow-col gap-6") do
          a(
            href: "https://github.com/unidel2035/a2d2",
            target: "_blank",
            rel: "noopener",
            class: "text-2xl hover:text-primary transition-colors",
            aria: { label: "GitHub" }
          ) do
            svg_github_icon
          end
        end

        div do
          p(class: "text-sm text-base-content/60") do
            text "© 2025 A2D2. Разработано с 🇷🇺 в России"
          end
          p(class: "text-xs text-base-content/50") do
            text "MIT License • Ruby on Rails 8 • Open Source"
          end
        end
      end
    end

    # SVG иконки

    def svg_github_icon
      svg(xmlns: "http://www.w3.org/2000/svg", class: "h-5 w-5", fill: "currentColor", viewBox: "0 0 24 24") do |s|
        s.path(d: "M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z")
      end
    end

    def svg_sparkles_icon
      svg(xmlns: "http://www.w3.org/2000/svg", class: "h-4 w-4", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do |s|
        s.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z")
      end
    end

    def svg_rocket_icon
      svg(xmlns: "http://www.w3.org/2000/svg", class: "h-6 w-6", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do |s|
        s.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M13 10V3L4 14h7v7l9-11h-7z")
      end
    end

    def svg_play_icon
      svg(xmlns: "http://www.w3.org/2000/svg", class: "h-6 w-6", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do |s|
        s.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z")
        s.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M21 12a9 9 0 11-18 0 9 9 0 0118 0z")
      end
    end

    def svg_cpu_icon
      svg(xmlns: "http://www.w3.org/2000/svg", class: "h-10 w-10", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do |s|
        s.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z")
      end
    end

    def svg_brain_icon
      svg(xmlns: "http://www.w3.org/2000/svg", class: "h-10 w-10", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do |s|
        s.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z")
      end
    end

    def svg_clock_icon
      svg(xmlns: "http://www.w3.org/2000/svg", class: "h-10 w-10", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do |s|
        s.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z")
      end
    end

    def svg_check_circle_icon(color = "primary")
      svg(xmlns: "http://www.w3.org/2000/svg", class: "h-6 w-6 text-#{color}", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do |s|
        s.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z")
      end
    end

    def svg_chat_icon
      svg(xmlns: "http://www.w3.org/2000/svg", class: "h-5 w-5", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do |s|
        s.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z")
      end
    end
  end
end
