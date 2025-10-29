# frozen_string_literal: true

module AgroPlatform
  class IndexView < ApplicationComponent
    def initialize(ecosystem_status:, active_coordinations:, pending_tasks:, active_contracts:, recent_tasks:, recent_contracts:)
      @ecosystem_status = ecosystem_status
      @active_coordinations = active_coordinations
      @pending_tasks = pending_tasks
      @active_contracts = active_contracts
      @recent_tasks = recent_tasks
      @recent_contracts = recent_contracts
    end

    def view_template
      div(class: "container mx-auto px-4 py-8") do
        render_header
        render_status_overview
        render_architecture_levels
        render_quick_actions_and_contracts
        render_recent_activity
      end
    end

    private

    def render_header
      div(class: "mb-8") do
        h1(class: "text-4xl font-bold text-gray-900 mb-2") do
          "Код Урожая - Цифровая Экосистема АПК"
        end
        p(class: "text-lg text-gray-600") do
          "Мультиагентная платформа управления агропромышленным комплексом"
        end
      end
    end

    def render_status_overview
      div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8") do
        render_status_card(
          "Активные Агенты",
          @ecosystem_status[:active_agents].to_s,
          "из #{@ecosystem_status[:total_agents]} всего",
          "blue",
          "users"
        )

        render_status_card(
          "Активные Координации",
          @active_coordinations.to_s,
          "мультиагентные процессы",
          "green",
          "bolt"
        )

        render_status_card(
          "Задачи в Очереди",
          @pending_tasks.to_s,
          "ожидают выполнения",
          "yellow",
          "clipboard"
        )

        render_status_card(
          "Активные Контракты",
          @active_contracts.to_s,
          "смарт-контракты",
          "purple",
          "document-text"
        )
      end
    end

    def render_status_card(title, value, description, color, icon)
      div(class: "bg-white rounded-lg shadow-md p-6 border-l-4 border-#{color}-500") do
        div(class: "flex items-center justify-between") do
          div do
            p(class: "text-sm text-gray-600 uppercase tracking-wide") { title }
            p(class: "text-3xl font-bold text-gray-900") { value }
            p(class: "text-xs text-gray-500 mt-1") { description }
          end

          div(class: "text-#{color}-500") do
            render_icon(icon, "w-12 h-12")
          end
        end
      end
    end

    def render_architecture_levels
      div(class: "bg-white rounded-lg shadow-md p-6 mb-8") do
        h2(class: "text-2xl font-bold text-gray-900 mb-4") do
          "Трехуровневая Архитектура Экосистемы"
        end

        div(class: "grid grid-cols-1 md:grid-cols-3 gap-6") do
          render_level_card(
            "Уровень 1: IoT / БИПО",
            "Безопасный Интернет Подвижных Объектов",
            ["Телематика и навигация", "Беспилотная техника", "Сбор данных IoT", "M2M коммуникации"],
            "#",
            "Управление оборудованием →",
            "blue"
          )

          render_level_card(
            "Уровень 2: Микро/Мезо",
            "Федеративная мультиагентная платформа",
            ["Фермерские хозяйства", "Логистика и транспорт", "Переработка", "Смарт-контракты"],
            helpers.agro_platform_ecosystem_path,
            "Экосистема агентов →",
            "green"
          )

          render_level_card(
            "Уровень 3: Макро",
            "Межотраслевая кооперация",
            ["Машиностроение", "Химическая промышленность", "Энергетика", "Ритейл и HoReCa"],
            "#",
            "Межотраслевые связи →",
            "purple"
          )
        end
      end
    end

    def render_level_card(title, subtitle, features, link_href, link_text, color)
      div(class: "border-2 border-gray-200 rounded-lg p-6 hover:border-#{color}-500 transition") do
        h3(class: "text-xl font-bold text-gray-900 mb-2") { title }
        p(class: "text-sm text-gray-600 mb-4") { subtitle }

        ul(class: "text-sm text-gray-700 space-y-2") do
          features.each do |feature|
            li { "• #{feature}" }
          end
        end

        a(
          href: link_href,
          class: "text-#{color}-500 text-sm mt-4 inline-block"
        ) { link_text }
      end
    end

    def render_quick_actions_and_contracts
      div(class: "grid grid-cols-1 md:grid-cols-2 gap-6 mb-8") do
        render_quick_actions
        render_recent_contracts
      end
    end

    def render_quick_actions
      div(class: "bg-white rounded-lg shadow-md p-6") do
        h2(class: "text-xl font-bold text-gray-900 mb-4") { "Быстрые Действия" }

        div(class: "space-y-3") do
          render_action_link(helpers.agro_agents_path, "Управление Агентами", "blue")
          render_action_link(helpers.farms_path, "Фермерские Хозяйства", "green")
          render_action_link(helpers.market_offers_path, "Маркетплейс", "yellow")
          render_action_link(helpers.agro_platform_monitoring_path, "Мониторинг Системы", "purple")
        end
      end
    end

    def render_action_link(href, label, color)
      a(href: href, class: "block bg-#{color}-50 hover:bg-#{color}-100 rounded-lg p-4 transition") do
        div(class: "flex items-center justify-between") do
          span(class: "font-medium text-#{color}-900") { label }

          svg(
            class: "w-5 h-5 text-#{color}-500",
            fill: "none",
            stroke: "currentColor",
            viewBox: "0 0 24 24",
            xmlns: "http://www.w3.org/2000/svg"
          ) do
            path(
              stroke_linecap: "round",
              stroke_linejoin: "round",
              stroke_width: "2",
              d: "M9 5l7 7-7 7"
            )
          end
        end
      end
    end

    def render_recent_contracts
      div(class: "bg-white rounded-lg shadow-md p-6") do
        h2(class: "text-xl font-bold text-gray-900 mb-4") { "Последние Контракты" }

        div(class: "space-y-3") do
          if @recent_contracts.any?
            @recent_contracts.each do |contract|
              render_contract_item(contract)
            end
          else
            p(class: "text-gray-500 text-sm") { "Нет активных контрактов" }
          end
        end
      end
    end

    def render_contract_item(contract)
      border_color = contract.status == "active" ? "border-green-500" : "border-gray-300"

      div(class: "border-l-4 #{border_color} pl-4 py-2") do
        div(class: "flex items-center justify-between") do
          div do
            p(class: "font-medium text-gray-900") do
              contract.contract_type.titleize
            end
            p(class: "text-sm text-gray-600") do
              "#{contract.buyer_agent.name} ↔ #{contract.seller_agent.name}"
            end
          end

          status_class = contract.status == "active" ?
            "bg-green-100 text-green-800" : "bg-gray-100 text-gray-800"

          span(class: "px-3 py-1 text-xs font-medium rounded-full #{status_class}") do
            contract.status
          end
        end
      end
    end

    def render_recent_activity
      div(class: "bg-white rounded-lg shadow-md p-6") do
        h2(class: "text-xl font-bold text-gray-900 mb-4") { "Последние Задачи" }

        div(class: "overflow-x-auto") do
          table(class: "min-w-full divide-y divide-gray-200") do
            thead(class: "bg-gray-50") do
              tr do
                th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") do
                  "Агент"
                end
                th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") do
                  "Тип Задачи"
                end
                th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") do
                  "Приоритет"
                end
                th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") do
                  "Статус"
                end
                th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") do
                  "Время"
                end
              end
            end

            tbody(class: "bg-white divide-y divide-gray-200") do
              if @recent_tasks.any?
                @recent_tasks.each do |task|
                  render_task_row(task)
                end
              else
                tr do
                  td(colspan: "5", class: "px-6 py-4 text-center text-sm text-gray-500") do
                    "Нет задач"
                  end
                end
              end
            end
          end
        end
      end
    end

    def render_task_row(task)
      tr do
        td(class: "px-6 py-4 whitespace-nowrap text-sm text-gray-900") do
          a(
            href: helpers.agro_agent_path(task.agro_agent),
            class: "text-blue-600 hover:text-blue-800"
          ) { task.agro_agent.name }
        end

        td(class: "px-6 py-4 whitespace-nowrap text-sm text-gray-900") do
          task.task_type
        end

        td(class: "px-6 py-4 whitespace-nowrap") do
          priority_class = case task.priority
          when "critical" then "bg-red-100 text-red-800"
          when "high" then "bg-orange-100 text-orange-800"
          else "bg-blue-100 text-blue-800"
          end

          span(class: "px-2 inline-flex text-xs leading-5 font-semibold rounded-full #{priority_class}") do
            task.priority
          end
        end

        td(class: "px-6 py-4 whitespace-nowrap") do
          status_class = case task.status
          when "completed" then "bg-green-100 text-green-800"
          when "in_progress" then "bg-yellow-100 text-yellow-800"
          when "failed" then "bg-red-100 text-red-800"
          else "bg-gray-100 text-gray-800"
          end

          span(class: "px-2 inline-flex text-xs leading-5 font-semibold rounded-full #{status_class}") do
            task.status
          end
        end

        td(class: "px-6 py-4 whitespace-nowrap text-sm text-gray-500") do
          "#{helpers.time_ago_in_words(task.created_at)} назад"
        end
      end
    end

    def render_icon(icon_name, size_class)
      icon_paths = {
        "users" => "M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z",
        "bolt" => "M13 10V3L4 14h7v7l9-11h-7z",
        "clipboard" => "M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2",
        "document-text" => "M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
      }

      svg(
        class: size_class,
        fill: "none",
        stroke: "currentColor",
        viewBox: "0 0 24 24",
        xmlns: "http://www.w3.org/2000/svg"
      ) do
        path(
          stroke_linecap: "round",
          stroke_linejoin: "round",
          stroke_width: "2",
          d: icon_paths[icon_name] || ""
        )
      end
    end
  end
end
