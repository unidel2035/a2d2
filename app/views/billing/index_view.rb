# frozen_string_literal: true

module Billing
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
        title { "Тарифы и оплата - A2D2" }
        meta(name: "viewport", content: "width=device-width,initial-scale=1")
        helpers.csrf_meta_tags
        helpers.csp_meta_tag

        helpers.stylesheet_link_tag "application", data: { turbo_track: "reload" }
        script(src: "https://cdn.tailwindcss.com")
        link(
          href: "https://cdn.jsdelivr.net/npm/daisyui@4.12.14/dist/full.min.css",
          rel: "stylesheet",
          type: "text/css"
        )
        helpers.javascript_importmap_tags
      end
    end

    def render_body
      body(class: "bg-base-200") do
        render Components::NavbarComponent.new(
          logged_in: @logged_in,
          current_user: @current_user,
          show_dashboard: true
        )

        # Hero section
        render_hero_section

        # Pricing cards
        render_pricing_section

        # Features comparison
        render_comparison_section

        # FAQ
        render_faq_section

        render Components::FooterComponent.new
      end
    end

    def render_hero_section
      div(class: "relative py-24 bg-gradient-to-br from-purple-900 via-blue-900 to-indigo-900 overflow-hidden") do
        # Background effects
        div(class: "absolute inset-0 opacity-10") do
          div(class: "absolute top-1/4 left-1/4 w-96 h-96 bg-purple-500 rounded-full mix-blend-multiply filter blur-3xl animate-pulse")
          div(class: "absolute top-1/3 right-1/4 w-96 h-96 bg-blue-500 rounded-full mix-blend-multiply filter blur-3xl animate-pulse animation-delay-2000")
        end

        div(class: "container mx-auto px-4 text-center relative z-10") do
          # Badge
          div(class: "mb-6") do
            Badge class: "badge-lg bg-white/10 border-white/20 text-white backdrop-blur-sm px-6 py-3" do
              plain "💰 "
              span(class: "font-semibold") { "Прозрачное ценообразование" }
            end
          end

          h1(class: "text-6xl md:text-7xl font-black text-white mb-6") do
            plain "Выберите свой "
            br(class: "hidden md:block")
            span(class: "bg-gradient-to-r from-yellow-200 to-pink-200 bg-clip-text text-transparent") do
              "тарифный план"
            end
          end

          p(class: "text-xl text-white/80 mb-8 max-w-2xl mx-auto") do
            "Гибкие тарифы для любого размера бизнеса. Начните бесплатно, масштабируйтесь по мере роста."
          end

          # Billing toggle
          div(class: "flex justify-center items-center gap-4 mb-4") do
            span(class: "text-white/70") { "Ежемесячно" }
            Toggle :primary, :lg, checked: true, class: "toggle-lg"
            span(class: "text-white font-semibold") do
              plain "Ежегодно "
              Badge :success, class: "badge-sm ml-1" do
                "Скидка 20%"
              end
            end
          end
        end
      end
    end

    def render_pricing_section
      div(class: "py-20 bg-base-100") do
        div(class: "container mx-auto px-4") do
          div(class: "grid grid-cols-1 md:grid-cols-3 gap-8 max-w-6xl mx-auto") do
            # Free plan
            render_pricing_card(
              "Старт",
              "Бесплатно",
              "Для изучения и тестирования",
              "0₽",
              "/месяц",
              [
                "До 3 ИИ-агентов",
                "100 запросов в месяц",
                "Базовая аналитика",
                "Community поддержка",
                "1 пользователь"
              ],
              :neutral,
              "Начать бесплатно",
              false
            )

            # Pro plan (highlighted)
            render_pricing_card(
              "Профессионал",
              "Популярный",
              "Для растущих команд",
              "9 900₽",
              "/месяц",
              [
                "До 20 ИИ-агентов",
                "10 000 запросов в месяц",
                "Расширенная аналитика",
                "Email поддержка 24/7",
                "До 10 пользователей",
                "API доступ",
                "Кастомные интеграции"
              ],
              :primary,
              "Попробовать 30 дней бесплатно",
              true
            )

            # Enterprise plan
            render_pricing_card(
              "Корпоративный",
              "Масштаб",
              "Для крупных компаний",
              "По запросу",
              "",
              [
                "Неограниченно агентов",
                "Неограниченно запросов",
                "Полная аналитика + BI",
                "Dedicated менеджер",
                "Неограниченно пользователей",
                "Priority API",
                "On-premise развертывание",
                "SLA 99.9%"
              ],
              :secondary,
              "Связаться с отделом продаж",
              false
            )
          end
        end
      end
    end

    def render_pricing_card(name, badge, subtitle, price, period, features, color, button_text, featured)
      div(class: "relative #{featured ? 'md:-mt-8' : ''}") do
        # Featured badge
        if featured
          div(class: "absolute -top-4 left-1/2 -translate-x-1/2 z-10") do
            Badge :#{color}, class: "badge-lg shadow-lg" do
              "✨ Рекомендуем"
            end
          end
        end

        # Glow effect for featured
        if featured
          div(class: "absolute inset-0 bg-gradient-to-r from-#{color} to-#{color} rounded-3xl opacity-20 blur-xl")
        end

        Card :base_100, class: "relative shadow-xl hover:shadow-2xl transition-all duration-300 #{featured ? 'border-4 border-' + color.to_s : 'border-2 border-base-300'}" do |card|
          card.body class: "p-8" do
            # Header
            div(class: "text-center mb-6") do
              Badge :#{color}, class: "badge-lg mb-3" do
                badge
              end
              h3(class: "text-2xl font-bold mb-2") { name }
              p(class: "text-sm text-base-content/60") { subtitle }
            end

            # Price
            div(class: "text-center mb-8") do
              div(class: "flex items-end justify-center gap-1") do
                span(class: "text-5xl font-black bg-gradient-to-r from-#{color} to-#{color} bg-clip-text text-transparent") do
                  price
                end
                if period != ""
                  span(class: "text-base-content/60 mb-2") { period }
                end
              end
            end

            # Features
            div(class: "space-y-4 mb-8") do
              features.each do |feature|
                div(class: "flex items-start gap-3") do
                  div(class: "flex-shrink-0 mt-1") do
                    svg(
                      xmlns: "http://www.w3.org/2000/svg",
                      class: "h-5 w-5 text-#{color}",
                      fill: "none",
                      viewBox: "0 0 24 24",
                      stroke: "currentColor"
                    ) do
                      path(
                        stroke_linecap: "round",
                        stroke_linejoin: "round",
                        stroke_width: "2",
                        d: "M5 13l4 4L19 7"
                      )
                    end
                  end
                  span(class: "text-base-content") { feature }
                end
              end
            end

            # CTA button
            Button :#{color}, :block, :lg, class: "#{featured ? 'shadow-lg' : ''}" do
              button_text
            end
          end
        end
      end
    end

    def render_comparison_section
      div(class: "py-20 bg-base-200") do
        div(class: "container mx-auto px-4") do
          h2(class: "text-4xl font-bold text-center mb-12 bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent") do
            "Детальное сравнение тарифов"
          end

          div(class: "overflow-x-auto") do
            table(class: "table w-full") do
              thead do
                tr do
                  th { "Возможность" }
                  th(class: "text-center") { "Старт" }
                  th(class: "text-center bg-primary/10") { "Профессионал" }
                  th(class: "text-center") { "Корпоративный" }
                end
              end
              tbody do
                render_comparison_row("ИИ-агенты", "До 3", "До 20", "Неограниченно")
                render_comparison_row("Запросы в месяц", "100", "10 000", "Неограниченно")
                render_comparison_row("Пользователи", "1", "10", "Неограниченно")
                render_comparison_row("API доступ", false, true, true)
                render_comparison_row("Аналитика", "Базовая", "Расширенная", "Полная + BI")
                render_comparison_row("Поддержка", "Community", "Email 24/7", "Dedicated")
                render_comparison_row("SLA", "-", "99%", "99.9%")
                render_comparison_row("On-premise", false, false, true)
              end
            end
          end
        end
      end
    end

    def render_comparison_row(feature, free, pro, enterprise)
      tr do
        td(class: "font-semibold") { feature }
        td(class: "text-center") do
          render_comparison_value(free)
        end
        td(class: "text-center bg-primary/5") do
          render_comparison_value(pro)
        end
        td(class: "text-center") do
          render_comparison_value(enterprise)
        end
      end
    end

    def render_comparison_value(value)
      if value == true
        Badge :success do
          "✓"
        end
      elsif value == false
        Badge :ghost do
          "—"
        end
      else
        plain value
      end
    end

    def render_faq_section
      div(class: "py-20 bg-base-100") do
        div(class: "container mx-auto px-4 max-w-4xl") do
          h2(class: "text-4xl font-bold text-center mb-12 bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent") do
            "Часто задаваемые вопросы"
          end

          Accordion do
            render_faq_item(
              "Можно ли сменить тариф в любое время?",
              "Да, вы можете повысить или понизить тариф в любое время. При повышении тарифа вы получите доступ к новым функциям немедленно. При понижении изменения вступят в силу с начала следующего платежного периода.",
              true
            )

            render_faq_item(
              "Есть ли скрытые платежи?",
              "Нет, все цены полностью прозрачны. Вы платите только за выбранный тариф. Нет скрытых комиссий или дополнительных сборов.",
              false
            )

            render_faq_item(
              "Какие способы оплаты доступны?",
              "Мы принимаем банковские карты (Visa, MasterCard, МИР), банковские переводы для юридических лиц, а также криптовалюту (BTC, ETH, USDT).",
              false
            )

            render_faq_item(
              "Что происходит после окончания бесплатного периода?",
              "После окончания 30-дневного пробного периода вы можете выбрать платный тариф для продолжения работы. Если вы не выберете тариф, аккаунт будет переведен на бесплатный план с ограниченным функционалом.",
              false
            )

            render_faq_item(
              "Можно ли получить возврат средств?",
              "Да, мы предлагаем 14-дневную гарантию возврата денег. Если платформа вам не подошла, мы вернем полную стоимость подписки без вопросов.",
              false
            )
          end
        end
      end
    end

    def render_faq_item(question, answer, open = false)
      Collapse :arrow, class: "border border-base-300 bg-base-100 mb-2" do |collapse|
        input(type: "radio", name: "faq-accordion", checked: open)
        collapse.title(class: "text-lg font-semibold") { question }
        collapse.content do
          p(class: "text-base-content/70") { answer }
        end
      end
    end
  end
end
