# frozen_string_literal: true

module Dashboard
  class IndexView < ApplicationComponent
    def view_template
      # Dashboard Header
      div(class: "mb-6") do
        h1(class: "text-3xl font-bold mb-2") { "Dashboard" }
        p(class: "text-base-content/70") { "Welcome to A2D2 - Your Robotization & AI Agents Management System" }
      end

      # Quick Actions
      render_quick_actions

      # Stats Cards
      render_stats_cards

      # Charts Row
      render_charts_row

      # Recent Activity
      render_recent_activity
    end

    private

    def render_quick_actions
      div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6") do
        render_action_button("#", "New Task", "rocket", "btn-primary")
        render_action_button("#", "New Inspection", "clipboard", "btn-secondary")
        render_action_button("#", "Add Robot", "plus", "btn-accent")
        render_action_button("#", "Generate Report", "chart-bar", "btn-info")
      end
    end

    def render_action_button(href, label, icon, btn_class)
      a(href: href, class: "btn #{btn_class} btn-lg justify-start gap-3") do
        render_icon(icon)
        plain label
      end
    end

    def render_stats_cards
      div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6") do
        render_stat_card("Total Robots", "24", "↗︎ 12% from last month", "primary", "rocket")
        render_stat_card("Active Tasks", "156", "↗︎ 23% from last week", "secondary", "sparkles")
        render_stat_card("Needs Maintenance", "3", "2 robots require immediate attention", "error", "warning")
        render_stat_card("Active Operators", "18", "↗︎ 3 new this month", "info", "users")
      end
    end

    def render_stat_card(title, value, description, color, icon)
      div(class: "stats shadow") do
        div(class: "stat") do
          div(class: "stat-figure text-#{color}") do
            render_icon(icon, size: "h-10 w-10")
          end
          div(class: "stat-title") { title }
          div(class: "stat-value text-#{color}") { value }
          div(class: "stat-desc") { description }
        end
      end
    end

    def render_charts_row
      div(class: "grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6") do
        render_chart_card("Task Statistics", ["Week", "Month", "Year"])
        render_chart_card("Robot Usage", ["All", "Active"])
      end
    end

    def render_chart_card(title, buttons)
      div(class: "card bg-base-100 shadow-xl") do
        div(class: "card-body") do
          div(class: "flex justify-between items-center mb-4") do
            h2(class: "card-title") { title }
            div(class: "join") do
              buttons.each_with_index do |button, index|
                button_class = index == 0 ? "btn btn-sm join-item btn-active" : "btn btn-sm join-item"
                button(class: button_class) { button }
              end
            end
          end

          div(class: "bg-base-200 rounded-lg p-8 flex items-center justify-center h-64") do
            div(class: "text-center") do
              svg(
                xmlns: "http://www.w3.org/2000/svg",
                class: "h-16 w-16 mx-auto text-base-content/30 mb-4",
                fill: "none",
                viewBox: "0 0 24 24",
                stroke: "currentColor"
              ) do
                path(
                  stroke_linecap: "round",
                  stroke_linejoin: "round",
                  stroke_width: "2",
                  d: title.include?("Task") ?
                    "M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" :
                    "M11 3.055A9.001 9.001 0 1020.945 13H11V3.055z"
                )
              end
              p(class: "text-base-content/50") do
                title.include?("Task") ? "Chart visualization will be displayed here" : "Analytics loading..."
              end
            end
          end
        end
      end
    end

    def render_recent_activity
      div(class: "card bg-base-100 shadow-xl") do
        div(class: "card-body") do
          div(class: "flex justify-between items-center mb-4") do
            h2(class: "card-title") { "Recent Activity" }
            a(href: "#", class: "link link-primary") { "View All" }
          end

          div(class: "space-y-3") do
            render_activity_item(
              "Task Completed",
              "Robot Agent Pro completed inspection on Line #4523",
              "5 minutes ago",
              "success",
              "check"
            )
            render_activity_item(
              "New Inspection",
              "45 photos uploaded with GPS tags",
              "15 minutes ago",
              "info",
              "photo"
            )
            render_activity_item(
              "Maintenance Scheduled",
              "Robot System Alpha requires service in 3 days",
              "1 hour ago",
              "warning",
              "warning"
            )
            render_activity_item(
              "Operator Added",
              "Ivanov A.S. granted access to the system",
              "2 hours ago",
              "primary",
              "user-add"
            )
            render_activity_item(
              "Report Generated",
              "Monthly flight report is ready for download",
              "3 hours ago",
              "accent",
              "document"
            )
          end
        end
      end
    end

    def render_activity_item(title, description, time, color, icon)
      div(class: "flex items-start gap-4 p-4 bg-base-200 rounded-lg hover:bg-base-300 transition-colors") do
        div(class: "avatar placeholder") do
          div(class: "bg-#{color} text-#{color}-content rounded-full w-12") do
            render_activity_icon(icon)
          end
        end

        div(class: "flex-1") do
          h3(class: "font-semibold") { title }
          p(class: "text-sm text-base-content/70") { description }
          p(class: "text-xs text-base-content/50 mt-1") { time }
        end
      end
    end

    def render_activity_icon(icon_name)
      icon_paths = {
        "check" => "M5 13l4 4L19 7",
        "photo" => "M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z",
        "warning" => "M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z",
        "user-add" => "M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z",
        "document" => "M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
      }

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
          d: icon_paths[icon_name] || ""
        )
      end
    end

    def render_icon(icon_name, size: "h-6 w-6")
      svg_paths = {
        "rocket" => "M12 19l9 2-9-18-9 18 9-2zm0 0v-8",
        "clipboard" => "M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01",
        "plus" => "M12 6v6m0 0v6m0-6h6m-6 0H6",
        "chart-bar" => "M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z",
        "sparkles" => "M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z",
        "warning" => "M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z",
        "users" => "M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"
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
          d: svg_paths[icon_name] || ""
        )
      end
    end
  end
end
