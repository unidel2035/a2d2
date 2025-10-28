# frozen_string_literal: true

module Sessions
  class NewView < ApplicationComponent
    def initialize(flash: {})
      @flash = flash
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
        title { "Вход - A2D2" }
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
      end
    end

    def render_body
      body(class: "bg-gradient-to-br from-primary/10 to-secondary/10 min-h-screen flex items-center justify-center p-4") do
        div(class: "w-full max-w-md") do
          render_logo
          render_login_card
          render_back_link
        end
      end
    end

    def render_logo
      div(class: "text-center mb-8") do
        Link href: root_path, class: "inline-block" do
          h1(class: "text-5xl font-bold bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent mb-2") do
            "A2D2"
          end
        end
        p(class: "text-lg text-base-content/70") { "Войдите в систему" }
      end
    end

    def render_login_card
      Card :base_100, class: "shadow-2xl" do |card|
        card.body do
          card.title(class: "text-2xl mb-6 justify-center") { "Вход" }

          render_alert if @flash[:alert]
          render_login_form

          Divider { "или" }

          div(class: "text-center") do
            p(class: "text-base-content/70") do
              plain "Нет аккаунта? "
              Link(href: signup_path, class: "link link-primary font-semibold") do
                "Зарегистрироваться"
              end
            end
          end
        end
      end
    end

    def render_alert
      Alert :error do
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
            d: "M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"
          )
        end
        span { @flash[:alert] }
      end
    end

    def render_login_form
      form(action: login_path, method: "post", class: "space-y-4") do
        # CSRF token
        input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)

        # Email field
        FormControl do
          label(class: "label") do
            span(class: "label-text") { "Email" }
          end
          Input(
            type: "email",
            name: "email",
            placeholder: "your@email.com",
            class: "input-bordered w-full",
            autofocus: true,
            required: true
          )
        end

        # Password field
        FormControl do
          label(class: "label") do
            span(class: "label-text") { "Пароль" }
          end
          Input(
            type: "password",
            name: "password",
            placeholder: "Введите пароль",
            class: "input-bordered w-full",
            required: true
          )
        end

        # Remember me
        FormControl do
          label(class: "label cursor-pointer justify-start gap-2") do
            Checkbox :primary, name: "remember_me"
            span(class: "label-text") { "Запомнить меня" }
          end
        end

        # Submit button
        FormControl class: "mt-6" do
          Button :primary, :block, :lg, type: "submit" do
            "Войти"
          end
        end
      end
    end

    def render_back_link
      div(class: "text-center mt-6") do
        Link(href: root_path, class: "link link-neutral") do
          svg(
            xmlns: "http://www.w3.org/2000/svg",
            class: "h-5 w-5 inline-block mr-1",
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
  end
end
