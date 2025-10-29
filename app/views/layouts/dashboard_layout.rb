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
            raw <<~JS
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
            svg(
              xmlns: "http://www.w3.org/2000/svg",
              fill: "none",
              viewBox: "0 0 24 24",
              class: "inline-block w-6 h-6 stroke-current"
            ) do
              path(
                stroke_linecap: "round",
                stroke_linejoin: "round",
                stroke_width: "2",
                d: "M4 6h16M4 12h16M4 18h16"
              )
            end
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
                d: "M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"
              )
            end
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
      div(class: alert_class) do
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          class: "stroke-current shrink-0 h-6 w-6",
          fill: "none",
          viewBox: "0 0 24 24"
        ) do
          if type == "warning"
            path(
              stroke_linecap: "round",
              stroke_linejoin: "round",
              stroke_width: "2",
              d: "M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
            )
          else
            path(
              stroke_linecap: "round",
              stroke_linejoin: "round",
              stroke_width: "2",
              d: "M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
            )
          end
        end
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
      svg_paths = {
        "home" => "M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6",
        "chart" => "M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z",
        "rocket" => "M12 19l9 2-9-18-9 18 9-2zm0 0v-8",
        "sparkles" => "M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z",
        "users" => "M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z",
        "clipboard" => "M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01",
        "document" => "M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z",
        "chart-bar" => "M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z",
        "cog" => "M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z",
        "adjustments" => "M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"
      }

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
          d: svg_paths[icon_name] || ""
        )
      end
    end
  end
end
