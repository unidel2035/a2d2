# frozen_string_literal: true

module Components
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
        title { "Компоненты дизайна - A2D2" }
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

        div(class: "container mx-auto p-6") do
          render_welcome_alert if @logged_in
          render_page_header
          render_quick_links
          render_all_components
          render_back_link
        end

        render Components::FooterComponent.new
      end
    end

    def render_welcome_alert
      if @current_user
        Alert :success, class: "mb-6" do |alert|
          svg(
            xmlns: "http://www.w3.org/2000/svg",
            class: "stroke-current shrink-0 h-6 w-6",
            fill: "none",
            viewBox: "0 0 24 24"
          ) do
            path(
              stroke_linecap: "round",
              stroke_linejoin: "round",
              stroke_width: "2",
              d: "M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
            )
          end
          span { "Добро пожаловать, #{@current_user.name}! Вы успешно вошли в систему." }
        end
      end
    end

    def render_page_header
      div(class: "mb-8") do
        h1(class: "text-4xl font-bold mb-2 bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent") do
          "Компоненты дизайна A2D2"
        end
        p(class: "text-lg text-base-content/70") do
          "Полная коллекция компонентов дизайн-системы на базе Tailwind CSS + DaisyUI + PhlexyUI"
        end
      end
    end

    def render_quick_links
      div(class: "flex flex-wrap gap-2 mb-8") do
        %w[actions data-display navigation feedback data-input layout mockup].each do |section|
          Link href: "##{section}", class: "btn btn-sm btn-outline" do
            section.split('-').map(&:capitalize).join(' ')
          end
        end
      end
    end

    def render_all_components
      render_actions_section
      render_data_display_section
      render_navigation_section
      render_feedback_section
      render_data_input_section
      render_layout_section
      render_mockup_section
    end

    def render_actions_section
      section(id: "actions", class: "mb-12") do
        h2(class: "text-3xl font-bold mb-6 text-primary") { "Действия (Actions)" }

        # Buttons
        component_card("Button (Кнопка)") do
          div(class: "space-y-6") do
            div do
              h4(class: "font-semibold mb-2") { "Основные стили:" }
              div(class: "flex flex-wrap gap-2") do
                Button { "Default" }
                Button :neutral { "Neutral" }
                Button :primary { "Primary" }
                Button :secondary { "Secondary" }
                Button :accent { "Accent" }
                Button :ghost { "Ghost" }
                Button :link { "Link" }
              end
            end

            div do
              h4(class: "font-semibold mb-2") { "Размеры:" }
              div(class: "flex flex-wrap gap-2 items-center") do
                Button :xs { "Tiny" }
                Button :sm { "Small" }
                Button { "Normal" }
                Button :lg { "Large" }
              end
            end

            div do
              h4(class: "font-semibold mb-2") { "С outline:" }
              div(class: "flex flex-wrap gap-2") do
                Button :outline { "Outline" }
                Button :outline, :primary { "Outline Primary" }
              end
            end
          end
        end

        # Modal
        component_card("Modal (Модальное окно)") do
          div(class: "flex flex-wrap gap-2") do
            Button :primary, onclick: "modal_basic.showModal()" do
              "Открыть модальное окно"
            end
          end

          tag(:dialog, id: "modal_basic", class: "modal") do
            Modal do |modal|
              modal.box do
                h3(class: "font-bold text-lg") { "Привет!" }
                p(class: "py-4") { "Это модальное окно, построенное с помощью PhlexyUI." }

                modal.action do
                  form(method: "dialog") do
                    Button { "Закрыть" }
                  end
                end
              end
            end
          end
        end
      end
    end

    def render_data_display_section
      section(id: "data-display", class: "mb-12") do
        h2(class: "text-3xl font-bold mb-6 text-primary") { "Отображение данных (Data Display)" }

        # Badge
        component_card("Badge (Бейдж)") do
          div(class: "flex flex-wrap gap-2") do
            Badge { "Default" }
            Badge :neutral { "Neutral" }
            Badge :primary { "Primary" }
            Badge :secondary { "Secondary" }
            Badge :accent { "Accent" }
            Badge :info { "Info" }
            Badge :success { "Success" }
            Badge :warning { "Warning" }
            Badge :error { "Error" }
          end
        end

        # Card
        component_card("Card (Карточка)") do
          div(class: "grid grid-cols-1 md:grid-cols-3 gap-4") do
            Card :base_200, class: "shadow-md" do |card|
              div(class: "bg-primary/20 h-32")
              card.body do
                card.title { "С изображением" }
                p { "Карточка с placeholder изображением." }
                card.actions class: "justify-end" do
                  Button :primary, :sm { "Действие" }
                end
              end
            end

            Card :base_200, class: "shadow-md" do |card|
              card.body do
                card.title { "Простая" }
                p { "Карточка без изображения." }
                card.actions class: "justify-end" do
                  Button :ghost, :sm { "Отмена" }
                  Button :primary, :sm { "OK" }
                end
              end
            end

            Card :primary, class: "text-primary-content shadow-md" do |card|
              card.body do
                card.title { "Цветная" }
                p { "Карточка с цветным фоном." }
                card.actions class: "justify-end" do
                  Button :sm { "Подробнее" }
                end
              end
            end
          end
        end

        # Accordion
        component_card("Accordion (Аккордеон)") do
          Accordion do
            Collapse :arrow, class: "border border-base-300" do |collapse|
              input(type: "radio", name: "accordion", checked: true)
              collapse.title(class: "text-xl font-medium") { "Раздел 1" }
              collapse.content do
                p { "Содержимое первого раздела аккордеона." }
              end
            end

            Collapse :arrow, class: "border border-base-300" do |collapse|
              input(type: "radio", name: "accordion")
              collapse.title(class: "text-xl font-medium") { "Раздел 2" }
              collapse.content do
                p { "Содержимое второго раздела аккордеона." }
              end
            end
          end
        end

        # Avatar
        component_card("Avatar (Аватар)") do
          div(class: "flex flex-wrap gap-2 items-center") do
            Avatar class: "w-12" do
              div(class: "bg-neutral text-neutral-content rounded flex items-center justify-center w-full h-full") { "A" }
            end
            Avatar class: "w-16" do
              div(class: "bg-primary text-primary-content rounded-full flex items-center justify-center w-full h-full") { "B" }
            end
            Avatar class: "w-20" do
              div(class: "bg-secondary text-secondary-content rounded-full flex items-center justify-center w-full h-full") { "C" }
            end
          end
        end
      end
    end

    def render_navigation_section
      section(id: "navigation", class: "mb-12") do
        h2(class: "text-3xl font-bold mb-6 text-primary") { "Навигация (Navigation)" }

        # Breadcrumbs
        component_card("Breadcrumbs (Хлебные крошки)") do
          Breadcrumbs do
            Link(href: "#") { "Главная" }
            Link(href: "#") { "Документы" }
            span { "Детали" }
          end
        end

        # Menu
        component_card("Menu (Меню)") do
          div(class: "grid grid-cols-1 md:grid-cols-2 gap-4") do
            Menu :vertical, class: "bg-base-200 rounded-box" do |menu|
              menu.item { Link(href: "#") { "Пункт 1" } }
              menu.item { Link(href: "#") { "Пункт 2" } }
              menu.item { Link(href: "#") { "Пункт 3" } }
            end

            Menu :vertical, class: "bg-base-200 rounded-box" do |menu|
              menu.title { "Категория" }
              menu.item { Link(href: "#") { "Подпункт 1" } }
              menu.item { Link(href: "#") { "Подпункт 2" } }
            end
          end
        end

        # Pagination
        component_card("Pagination (Пагинация)") do
          Join do
            Button :join_item { "«" }
            Button :join_item { "Страница 22" }
            Button :join_item { "»" }
          end
        end

        # Tabs
        component_card("Tabs (Вкладки)") do
          Tabs :boxed do
            Link(role: "tab", class: "tab") { "Tab 1" }
            Link(role: "tab", class: "tab tab-active") { "Tab 2" }
            Link(role: "tab", class: "tab") { "Tab 3" }
          end
        end
      end
    end

    def render_feedback_section
      section(id: "feedback", class: "mb-12") do
        h2(class: "text-3xl font-bold mb-6 text-primary") { "Обратная связь (Feedback)" }

        # Alerts
        component_card("Alert (Оповещение)") do
          div(class: "space-y-4") do
            Alert :info do |alert|
              svg(
                xmlns: "http://www.w3.org/2000/svg",
                fill: "none",
                viewBox: "0 0 24 24",
                class: "stroke-current shrink-0 w-6 h-6"
              ) do
                path(
                  stroke_linecap: "round",
                  stroke_linejoin: "round",
                  stroke_width: "2",
                  d: "M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                )
              end
              span { "Информационное сообщение" }
            end

            Alert :success do
              span { "Операция выполнена успешно!" }
            end

            Alert :warning do
              span { "Предупреждение!" }
            end

            Alert :error do
              span { "Ошибка!" }
            end
          end
        end

        # Loading
        component_card("Loading (Загрузка)") do
          div(class: "space-y-4") do
            div do
              h4(class: "font-semibold mb-2") { "Spinner:" }
              div(class: "flex gap-4") do
                Loading :spinner, :xs
                Loading :spinner, :sm
                Loading :spinner, :md
                Loading :spinner, :lg
              end
            end

            div do
              h4(class: "font-semibold mb-2") { "Dots:" }
              div(class: "flex gap-4") do
                Loading :dots, :xs
                Loading :dots, :sm
                Loading :dots, :md
                Loading :dots, :lg
              end
            end
          end
        end

        # Progress
        component_card("Progress (Прогресс)") do
          div(class: "space-y-2") do
            Progress value: 0, max: 100
            Progress :primary, value: 25, max: 100
            Progress :secondary, value: 50, max: 100
            Progress :accent, value: 75, max: 100
            Progress :success, value: 100, max: 100
          end
        end

        # Tooltip
        component_card("Tooltip (Подсказка)") do
          div(class: "flex flex-wrap gap-2") do
            Tooltip "Подсказка сверху" do
              Button { "Сверху" }
            end
            Tooltip "Подсказка снизу", position: :bottom do
              Button { "Снизу" }
            end
            Tooltip "Primary", position: :right, color: :primary do
              Button :primary { "Primary" }
            end
          end
        end
      end
    end

    def render_data_input_section
      section(id: "data-input", class: "mb-12") do
        h2(class: "text-3xl font-bold mb-6 text-primary") { "Ввод данных (Data Input)" }

        # Checkbox
        component_card("Checkbox (Чекбокс)") do
          div(class: "flex flex-wrap gap-4") do
            FormControl do
              label(class: "label cursor-pointer gap-2") do
                Checkbox checked: true
                span(class: "label-text") { "Default" }
              end
            end

            FormControl do
              label(class: "label cursor-pointer gap-2") do
                Checkbox :primary, checked: true
                span(class: "label-text") { "Primary" }
              end
            end

            FormControl do
              label(class: "label cursor-pointer gap-2") do
                Checkbox :secondary, checked: true
                span(class: "label-text") { "Secondary" }
              end
            end
          end
        end

        # Radio
        component_card("Radio (Радио кнопка)") do
          div(class: "flex flex-wrap gap-4") do
            FormControl do
              label(class: "label cursor-pointer gap-2") do
                Radio name: "radio-demo", checked: true
                span(class: "label-text") { "Опция 1" }
              end
            end

            FormControl do
              label(class: "label cursor-pointer gap-2") do
                Radio name: "radio-demo"
                span(class: "label-text") { "Опция 2" }
              end
            end
          end
        end

        # Text Input
        component_card("Text Input (Текстовое поле)") do
          div(class: "space-y-4") do
            Input type: "text", placeholder: "Текст", class: "input-bordered w-full max-w-xs"
            Input :primary, type: "text", placeholder: "Primary", class: "input-bordered w-full max-w-xs"
            Input :secondary, type: "text", placeholder: "Secondary", class: "input-bordered w-full max-w-xs"
          end
        end

        # Textarea
        component_card("Textarea (Текстовая область)") do
          div(class: "space-y-4") do
            Textarea placeholder: "Текст", class: "textarea-bordered w-full"
            Textarea :primary, placeholder: "Primary", class: "textarea-bordered w-full"
          end
        end

        # Toggle
        component_card("Toggle (Переключатель)") do
          div(class: "flex flex-wrap gap-4") do
            Toggle checked: true
            Toggle :primary, checked: true
            Toggle :secondary, checked: true
            Toggle :accent, checked: true
          end
        end

        # Select
        component_card("Select (Выпадающий список)") do
          div(class: "space-y-4") do
            Select class: "select-bordered w-full max-w-xs" do
              option(disabled: true, selected: true) { "Выберите" }
              option { "Опция 1" }
              option { "Опция 2" }
            end

            Select :primary, class: "select-bordered w-full max-w-xs" do
              option(disabled: true, selected: true) { "Primary" }
              option { "Опция 1" }
              option { "Опция 2" }
            end
          end
        end
      end
    end

    def render_layout_section
      section(id: "layout", class: "mb-12") do
        h2(class: "text-3xl font-bold mb-6 text-primary") { "Макет (Layout)" }

        # Divider
        component_card("Divider (Разделитель)") do
          div(class: "flex flex-col w-full") do
            div(class: "grid h-20 card bg-base-300 rounded-box place-items-center") { "Содержимое 1" }
            Divider { "ИЛИ" }
            div(class: "grid h-20 card bg-base-300 rounded-box place-items-center") { "Содержимое 2" }
          end
        end

        # Hero
        component_card("Hero (Героический блок)") do
          Hero class: "min-h-64 bg-base-200 rounded-box" do |hero|
            hero.content class: "text-center" do
              div(class: "max-w-md") do
                h1(class: "text-5xl font-bold") { "Привет!" }
                p(class: "py-6") { "Добро пожаловать на нашу страницу" }
                Button :primary { "Начать" }
              end
            end
          end
        end

        # Join
        component_card("Join (Соединение элементов)") do
          Join do
            Button :join_item { "Button 1" }
            Button :join_item { "Button 2" }
            Button :join_item { "Button 3" }
          end
        end
      end
    end

    def render_mockup_section
      section(id: "mockup", class: "mb-12") do
        h2(class: "text-3xl font-bold mb-6 text-primary") { "Макеты устройств (Mockup)" }

        # Code Mockup
        component_card("Code Mockup (Макет кода)") do
          Mockup :code do
            pre(data_prefix: "$") do
              code { "npm install phlexy_ui" }
            end
            pre(data_prefix: ">", class: "text-warning") do
              code { "installing..." }
            end
            pre(data_prefix: ">", class: "text-success") do
              code { "Done!" }
            end
          end
        end
      end
    end

    def render_back_link
      div(class: "text-center") do
        Link href: helpers.root_path, class: "btn btn-outline btn-lg" do
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
              d: "M10 19l-7-7m0 0l7-7m-7 7h18"
            )
          end
          plain "Вернуться на главную"
        end
      end
    end

    def component_card(title, &block)
      Card :base_100, class: "shadow-xl mb-8" do |card|
        card.body do
          card.title(class: "text-xl mb-4") { title }
          yield
        end
      end
    end
  end
end
