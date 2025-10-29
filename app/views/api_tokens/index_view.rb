# frozen_string_literal: true

module ApiTokens
  class IndexView < ApplicationComponent
    def initialize(current_user: nil)
      @current_user = current_user
    end

    def view_template
      # Hero section
      render_hero_section

      # API keys management
      render_tokens_section

      # API documentation preview
      render_documentation_section

      # Usage stats
      render_usage_section
    end

    private

    def render_hero_section
      div(class: "mb-8") do
        div(class: "flex flex-col md:flex-row md:items-center md:justify-between gap-4") do
          div do
            h1(class: "text-4xl font-black mb-2 bg-gradient-to-r from-primary via-secondary to-accent bg-clip-text text-transparent") do
              "API Токены"
            end
            p(class: "text-lg text-base-content/70") do
              "Управление токенами доступа к API платформы A2D2"
            end
          end

          Button :primary, class: "gap-2", onclick: "create_token_modal.showModal()" do
            render_icon("plus")
            plain "Создать новый токен"
          end
        end
      end
    end

    def render_tokens_section
      div(class: "mb-8") do
        Card :base_100, class: "shadow-xl" do |card|
          card.body do
            card.title(class: "flex items-center gap-2 mb-6") do
              render_icon("key")
              plain "Ваши API токены"
            end

            # Tokens list
            div(class: "space-y-4") do
              # Example token 1
              render_token_card(
                "Production API Key",
                "a2d2_prod_xxxxxxxxxxxxxxxxxx",
                "Создан 15 янв 2025",
                "Последнее использование: 2 часа назад",
                "Полный доступ",
                :success
              )

              # Example token 2
              render_token_card(
                "Development API Key",
                "a2d2_dev_yyyyyyyyyyyyyyyyyy",
                "Создан 10 дек 2024",
                "Последнее использование: 3 дня назад",
                "Только чтение",
                :info
              )

              # Example token 3
              render_token_card(
                "Testing API Key",
                "a2d2_test_zzzzzzzzzzzzzzzzzz",
                "Создан 5 дек 2024",
                "Не использовался",
                "Ограниченный доступ",
                :warning
              )
            end

            # Empty state (if no tokens)
            # div(class: "text-center py-12") do
            #   div(class: "text-6xl mb-4") { "🔑" }
            #   h3(class: "text-xl font-bold mb-2") { "У вас пока нет API токенов" }
            #   p(class: "text-base-content/70 mb-6") do
            #     "Создайте первый токен для начала работы с API"
            #   end
            #   Button :primary, class: "gap-2" do
            #     render_icon("plus")
            #     plain "Создать первый токен"
            #   end
            # end
          end
        end
      end
    end

    def render_token_card(name, token, created, last_used, permissions, status)
      div(class: "group") do
        Card :base_200, class: "hover:shadow-lg transition-all duration-300" do |card|
          card.body do
            div(class: "flex flex-col lg:flex-row lg:items-center justify-between gap-4") do
              # Token info
              div(class: "flex-1") do
                div(class: "flex items-center gap-3 mb-2") do
                  h3(class: "text-lg font-bold") { name }
                  Badge status.to_sym, class: "badge-sm" do
                    permissions
                  end
                end

                # Token value with copy button
                div(class: "flex items-center gap-2 mb-2") do
                  code(class: "bg-base-300 px-3 py-2 rounded text-sm font-mono flex-1") do
                    token
                  end
                  Button :ghost, :sm, class: "gap-1" do
                    render_icon("copy", size: "h-4 w-4")
                    plain "Копировать"
                  end
                end

                # Metadata
                div(class: "flex flex-wrap gap-4 text-sm text-base-content/70") do
                  div(class: "flex items-center gap-1") do
                    render_icon("calendar", size: "h-4 w-4")
                    plain created
                  end
                  div(class: "flex items-center gap-1") do
                    render_icon("clock", size: "h-4 w-4")
                    plain last_used
                  end
                end
              end

              # Actions
              div(class: "flex gap-2") do
                Button :info, :sm, :outline, class: "gap-1" do
                  render_icon("chart", size: "h-4 w-4")
                  plain "Статистика"
                end
                Button :warning, :sm, :outline, class: "gap-1" do
                  render_icon("edit", size: "h-4 w-4")
                  plain "Изменить"
                end
                Button :error, :sm, :outline, class: "gap-1" do
                  render_icon("trash", size: "h-4 w-4")
                  plain "Удалить"
                end
              end
            end
          end
        end
      end
    end

    def render_documentation_section
      div(class: "mb-8") do
        Card :base_100, class: "shadow-xl" do |card|
          card.body do
            card.title(class: "flex items-center gap-2 mb-6") do
              render_icon("book")
              plain "Быстрый старт с API"
            end

            Tabs :boxed, class: "mb-4" do
              a(role: "tab", class: "tab tab-active") { "cURL" }
              a(role: "tab", class: "tab") { "Python" }
              a(role: "tab", class: "tab") { "JavaScript" }
              a(role: "tab", class: "tab") { "Ruby" }
            end

            # Code example
            Mockup :code, class: "bg-neutral text-neutral-content" do
              pre(data_prefix: "$", class: "text-success") do
                code { "curl https://api.a2d2.ru/v1/agents \\" }
              end
              pre(data_prefix: ">", class: "text-warning") do
                code { '  -H "Authorization: Bearer YOUR_API_TOKEN" \\' }
              end
              pre(data_prefix: ">", class: "text-warning") do
                code { '  -H "Content-Type: application/json"' }
              end
            end

            div(class: "mt-6 flex gap-2") do
              Link href: "#", class: "btn btn-primary btn-sm gap-2" do
                render_icon("book", size: "h-4 w-4")
                plain "Полная документация"
              end
              Link href: "#", class: "btn btn-outline btn-sm gap-2" do
                render_icon("code", size: "h-4 w-4")
                plain "Примеры кода"
              end
            end
          end
        end
      end
    end

    def render_usage_section
      div(class: "grid grid-cols-1 lg:grid-cols-3 gap-6") do
        # Usage stats card
        Card :base_100, class: "shadow-xl" do |card|
          card.body do
            card.title(class: "text-lg") { "Использование API" }

            div(class: "space-y-4 mt-4") do
              # Requests this month
              div do
                div(class: "flex justify-between mb-2") do
                  span(class: "text-sm") { "Запросов в этом месяце" }
                  span(class: "font-bold") { "8,450 / 10,000" }
                end
                Progress :primary, value: 84, max: 100, class: "h-2"
              end

              # Rate limit
              div do
                div(class: "flex justify-between mb-2") do
                  span(class: "text-sm") { "Лимит запросов" }
                  span(class: "font-bold") { "100 / 100 req/min" }
                end
                Progress :success, value: 100, max: 100, class: "h-2"
              end

              # Storage
              div do
                div(class: "flex justify-between mb-2") do
                  span(class: "text-sm") { "Хранилище" }
                  span(class: "font-bold") { "2.4 GB / 10 GB" }
                end
                Progress :info, value: 24, max: 100, class: "h-2"
              end
            end
          end
        end

        # Rate limits card
        Card :base_100, class: "shadow-xl" do |card|
          card.body do
            card.title(class: "text-lg") { "Лимиты тарифа" }

            div(class: "space-y-3 mt-4") do
              render_limit_item("Запросов в месяц", "10,000")
              render_limit_item("Запросов в минуту", "100")
              render_limit_item("Агентов", "20")
              render_limit_item("Хранилище", "10 GB")
            end

            Button :outline, :block, :sm, class: "mt-6 gap-2" do
              render_icon("upgrade", size: "h-4 w-4")
              plain "Повысить лимиты"
            end
          end
        end

        # Security card
        Card :base_100, class: "shadow-xl" do |card|
          card.body do
            card.title(class: "text-lg") { "Безопасность" }

            div(class: "space-y-4 mt-4") do
              Alert :success, class: "text-sm" do
                render_icon("check", size: "h-4 w-4")
                plain "SSL/TLS шифрование"
              end

              Alert :success, class: "text-sm" do
                render_icon("check", size: "h-4 w-4")
                plain "Rate limiting активен"
              end

              Alert :warning, class: "text-sm" do
                render_icon("warning", size: "h-4 w-4")
                plain "IP whitelist не настроен"
              end
            end

            Button :outline, :block, :sm, class: "mt-6 gap-2" do
              render_icon("shield", size: "h-4 w-4")
              plain "Настроить безопасность"
            end
          end
        end
      end

      # Create token modal
      render_create_token_modal
    end

    def render_limit_item(label, value)
      div(class: "flex justify-between items-center") do
        span(class: "text-sm text-base-content/70") { label }
        Badge :ghost do
          value
        end
      end
    end

    def render_create_token_modal
      tag(:dialog, id: "create_token_modal", class: "modal") do
        Modal do |modal|
          modal.box do
            h3(class: "font-bold text-lg mb-4") { "Создать новый API токен" }

            form(method: "dialog", class: "space-y-4") do
              # Token name
              FormControl do
                label(class: "label") do
                  span(class: "label-text") { "Название токена" }
                end
                Input(
                  type: "text",
                  placeholder: "Production API Key",
                  class: "input-bordered w-full"
                )
              end

              # Permissions
              FormControl do
                label(class: "label") do
                  span(class: "label-text") { "Права доступа" }
                end
                Select class: "select-bordered w-full" do
                  option { "Полный доступ" }
                  option { "Только чтение" }
                  option { "Ограниченный доступ" }
                end
              end

              # Expiration
              FormControl do
                label(class: "label") do
                  span(class: "label-text") { "Срок действия" }
                end
                Select class: "select-bordered w-full" do
                  option { "Без ограничений" }
                  option { "30 дней" }
                  option { "90 дней" }
                  option { "1 год" }
                end
              end

              modal.action class: "flex gap-2 mt-6" do
                Button { "Отмена" }
                Button :primary do
                  "Создать токен"
                end
              end
            end
          end
        end
      end
    end

    def render_icon(type, size: "h-5 w-5")
      icons = {
        "key" => "M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z",
        "plus" => "M12 6v6m0 0v6m0-6h6m-6 0H6",
        "copy" => "M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z",
        "calendar" => "M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z",
        "clock" => "M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z",
        "chart" => "M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z",
        "edit" => "M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z",
        "trash" => "M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16",
        "book" => "M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253",
        "code" => "M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4",
        "upgrade" => "M7 11l5-5m0 0l5 5m-5-5v12",
        "check" => "M5 13l4 4L19 7",
        "warning" => "M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z",
        "shield" => "M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"
      }

      svg(
        xmlns: "http://www.w3.org/2000/svg",
        class: size,
        fill: "none",
        viewBox: "0 0 24 24",
        stroke: "currentColor"
      ) do
        path(
          stroke_linecap: "round",
          stroke_linejoin: "round",
          stroke_width: "2",
          d: icons[type] || ""
        )
      end
    end
  end
end
