# frozen_string_literal: true

module Components
  class NavbarComponent < ApplicationComponent
    def initialize(logged_in: false, current_user: nil, show_dashboard: false)
      @logged_in = logged_in
      @current_user = current_user
      @show_dashboard = show_dashboard
    end

    def template
      Navbar :base_100, class: "shadow-lg sticky top-0 z-50" do |navbar|
        # Navbar start
        div(class: "navbar-start") do
          Link href: root_path, class: "btn btn-ghost text-xl font-bold" do
            span(class: "bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent") { "A2D2" }
          end
        end

        # Navbar center
        if !@show_dashboard
          div(class: "navbar-center hidden lg:flex") do
            Menu :horizontal, class: "px-1" do |menu|
              menu.item { Link(href: "#features") { "Возможности" } }
              menu.item { Link(href: "#about") { "О проекте" } }
              menu.item { Link(href: components_path) { "Компоненты дизайна" } }
            end
          end
        else
          div(class: "navbar-center") do
            span(class: "text-lg font-semibold") { "Компоненты дизайна" }
          end
        end

        # Navbar end
        div(class: "navbar-end gap-2") do
          if @show_dashboard
            Link href: dashboard_path, class: "btn btn-ghost" do
              svg(
                xmlns: "http://www.w3.org/2000/svg",
                class: "h-5 w-5",
                fill: "none",
                viewBox: "0 0 24 24",
                stroke: "currentColor"
              ) do
                path(
                  stroke_linecap: "round",
                  stroke_linejoin: "round",
                  stroke_width: "2",
                  d: "M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"
                )
              end
              plain "Dashboard"
            end
          end

          if @logged_in
            Button :ghost, type: "submit", form: "logout-form" do
              "Выйти"
            end
            # Hidden form for logout
            form(id: "logout-form", action: logout_path, method: "post", style: "display:none;") do
              input(type: "hidden", name: "_method", value: "delete")
            end
          else
            Link href: login_path, class: "btn btn-ghost" do
              "Войти"
            end
            Link href: signup_path, class: "btn btn-primary" do
              "Регистрация"
            end
          end
        end
      end
    end
  end
end
