# frozen_string_literal: true

module Layouts
  class DashboardLayout < ApplicationComponent
    include Phlex::Rails::Layout

    def initialize(title: "A2D2 - Dashboard")
      @title = title
    end

    def view_template(&block)
      doctype

      html(data_theme: "light") do
        head do
          title { @title }
          meta(name: "viewport", content: "width=device-width,initial-scale=1")
          meta(name: "apple-mobile-web-app-capable", content: "yes")
          csrf_meta_tags
          csp_meta_tag

          stylesheet_link_tag "application", data: { turbo_track: "reload" }
          script(src: "https://cdn.tailwindcss.com")
          link(
            href: "https://cdn.jsdelivr.net/npm/daisyui@4.12.14/dist/full.min.css",
            rel: "stylesheet",
            type: "text/css"
          )
          script do
            plain <<~JS
              tailwind.config = {
                theme: {
                  extend: {
                    colors: {
                      primary: '#3b82f6',
                      secondary: '#6366f1',
                      accent: '#8b5cf6',
                    }
                  }
                }
              }
            JS
          end
          javascript_importmap_tags
        end

        body(class: "bg-base-200") do
          div(class: "drawer lg:drawer-open") do
            input(id: "drawer-toggle", type: "checkbox", class: "drawer-toggle")

            # Main Content
            div(class: "drawer-content flex flex-col") do
              render_top_navbar
              main(class: "flex-1 p-6") do
                yield
              end
            end

            # Sidebar
            render_sidebar
          end
        end
      end
    end

    private

    def render_top_navbar
      div(class: "navbar bg-base-100 shadow-lg sticky top-0 z-50") do
        div(class: "flex-none lg:hidden") do
          label(for: "drawer-toggle", class: "btn btn-square btn-ghost") do
            span(class: "text-2xl") { "☰" }
          end
        end

        div(class: "flex-1") do
          a(href: "/", class: "btn btn-ghost text-xl font-bold") { "A2D2" }
        end

        div(class: "flex-none gap-2") do
          render_search_bar
          render_notifications_dropdown
          render_user_profile_dropdown
        end
      end
    end

    def render_search_bar
      div(class: "form-control hidden md:block") do
        input(type: "text", placeholder: "Search...", class: "input input-bordered w-24 md:w-auto")
      end
    end

    def render_notifications_dropdown
      div(class: "dropdown dropdown-end") do
        label(tabindex: "0", class: "btn btn-ghost btn-circle") do
          div(class: "indicator") do
            span(class: "text-xl") { "🔔" }
            span(class: "badge badge-sm badge-error indicator-item") { "3" }
          end
        end

        div(tabindex: "0", class: "mt-3 z-[1] card card-compact dropdown-content w-80 bg-base-100 shadow-xl") do
          div(class: "card-body") do
            h3(class: "font-bold text-lg") { "Notifications" }
            div(class: "space-y-2") do
              render_notification_alert(
                "warning",
                "Maintenance required for Phantom 4"
              )
              render_notification_alert(
                "info",
                "New flight report available"
              )
            end
          end
        end
      end
    end

    def render_notification_alert(type, message)
      alert_class = type == "warning" ? "alert alert-warning" : "alert alert-info"
      icon = type == "warning" ? "⚠️" : "ℹ️"
      div(class: alert_class) do
        span(class: "text-xl") { icon }
        span(class: "text-sm") { message }
      end
    end

    def render_user_profile_dropdown
      div(class: "dropdown dropdown-end") do
        label(tabindex: "0", class: "btn btn-ghost btn-circle avatar") do
          div(class: "w-10 rounded-full bg-primary text-primary-content flex items-center justify-center") do
            span(class: "text-lg") { "A" }
          end
        end

        ul(tabindex: "0", class: "mt-3 z-[1] p-2 shadow menu menu-sm dropdown-content bg-base-100 rounded-box w-52") do
          li do
            a(class: "justify-between") do
              plain "Profile"
              span(class: "badge") { "New" }
            end
          end
          li { a { "Settings" } }
          li { a { "Logout" } }
        end
      end
    end

    def render_sidebar
      div(class: "drawer-side") do
        label(for: "drawer-toggle", class: "drawer-overlay")
        aside(class: "bg-base-100 w-80 min-h-full shadow-xl") do
          div(class: "sticky top-0") do
            div(class: "flex flex-col h-full") do
              ul(class: "menu p-4 space-y-2") do
                render_menu_section("Main") do
                  render_menu_item(helpers.dashboard_path, "Dashboard", "home", current_page: helpers.dashboard_path)
                  render_menu_item("#", "Analytics", "chart")
                end

                render_menu_section("Control") do
                  render_menu_item("#", "Robots", "rocket")
                  render_menu_item("#", "Tasks", "sparkles")
                  render_menu_item("#", "Operators", "users")
                  render_menu_item("#", "Inspections", "clipboard")
                end

                render_menu_section("Data") do
                  render_menu_item("#", "Documents", "document")
                  render_menu_item("#", "Reports", "chart-bar")
                end

                render_menu_section("System") do
                  render_menu_item("#", "Maintenance", "cog")
                  render_menu_item("#", "Settings", "adjustments")
                end
              end
            end
          end
        end
      end
    end

    def render_menu_section(title, &block)
      li(class: "menu-title mt-4") do
        span(class: "text-base-content/70") { title }
      end
      yield
    end

    def render_menu_item(href, label, icon, current_page: nil)
      active_class = (current_page && helpers.current_page?(href)) ? "active" : ""

      li do
        a(href: href, class: active_class) do
          render_icon(icon)
          plain label
        end
      end
    end

    def render_icon(icon_name)
      icons = {
        "home" => "🏠",
        "chart" => "📊",
        "rocket" => "🚀",
        "sparkles" => "✨",
        "users" => "👥",
        "clipboard" => "📋",
        "document" => "📄",
        "chart-bar" => "📊",
        "cog" => "⚙️",
        "adjustments" => "🎚️"
      }

      span { icons[icon_name] || "•" }
    end
  end
end
