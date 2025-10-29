# frozen_string_literal: true

module Agents
  class IndexView < ApplicationComponent
    def initialize(agents:, stats:, recent_tasks:)
      @agents = agents
      @stats = stats
      @recent_tasks = recent_tasks
    end

    def view_template
      div(class: "container mx-auto px-4 py-8") do
        h1(class: "text-3xl font-bold mb-6") { "Agent Orchestration Dashboard" }

        # Stats Cards
        render_stats_cards

        # Agents Table
        render_agents_table

        # Recent Tasks
        render_recent_tasks
      end
    end

    private

    def render_stats_cards
      div(class: "grid grid-cols-1 md:grid-cols-5 gap-4 mb-8") do
        render_stat_card("Total Agents", @stats[:total], "bg-white")
        render_stat_card("Active", @stats[:active], "bg-green-50", "text-green-600")
        render_stat_card("Idle", @stats[:idle], "bg-blue-50", "text-blue-600")
        render_stat_card("Busy", @stats[:busy], "bg-yellow-50", "text-yellow-600")
        render_stat_card("Failed", @stats[:failed], "bg-red-50", "text-red-600")
      end
    end

    def render_stat_card(title, value, bg_class, text_class = "")
      div(class: "#{bg_class} rounded-lg shadow p-6") do
        h3(class: "text-gray-500 text-sm font-medium") { title }
        p(class: "text-3xl font-bold #{text_class}") { value.to_s }
      end
    end

    def render_agents_table
      div(class: "bg-white rounded-lg shadow mb-8") do
        div(class: "px-6 py-4 border-b border-gray-200") do
          h2(class: "text-xl font-semibold") { "Registered Agents" }
        end

        div(class: "overflow-x-auto") do
          table(class: "min-w-full divide-y divide-gray-200") do
            thead(class: "bg-gray-50") do
              tr do
                th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Name" }
                th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Type" }
                th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Status" }
                th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Health Score" }
                th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Capabilities" }
                th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Last Heartbeat" }
                th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Actions" }
              end
            end

            tbody(class: "bg-white divide-y divide-gray-200") do
              @agents.each do |agent|
                render_agent_row(agent)
              end
            end
          end
        end
      end
    end

    def render_agent_row(agent)
      tr(class: "hover:bg-gray-50") do
        td(class: "px-6 py-4 whitespace-nowrap") do
          a(
            href: agent_path(agent),
            class: "text-blue-600 hover:text-blue-900 font-medium"
          ) { agent.name }
        end

        td(class: "px-6 py-4 whitespace-nowrap") { agent.agent_type }

        td(class: "px-6 py-4 whitespace-nowrap") do
          status_class = case agent.status
          when "idle" then "bg-green-100 text-green-800"
          when "busy" then "bg-yellow-100 text-yellow-800"
          when "failed" then "bg-red-100 text-red-800"
          else "bg-gray-100 text-gray-800"
          end

          span(class: "px-2 inline-flex text-xs leading-5 font-semibold rounded-full #{status_class}") do
            agent.status
          end
        end

        td(class: "px-6 py-4 whitespace-nowrap") do
          render_health_score(agent.health_score)
        end

        td(class: "px-6 py-4") do
          if agent.capabilities.present?
            div(class: "flex flex-wrap gap-1") do
              agent.capabilities.first(3).each do |cap|
                span(class: "px-2 py-1 text-xs bg-blue-100 text-blue-800 rounded") { cap }
              end

              if agent.capabilities.size > 3
                span(class: "px-2 py-1 text-xs bg-gray-100 text-gray-800 rounded") do
                  "+#{agent.capabilities.size - 3}"
                end
              end
            end
          else
            span(class: "text-gray-400 text-sm") { "None" }
          end
        end

        td(class: "px-6 py-4 whitespace-nowrap text-sm text-gray-500") do
          if agent.last_heartbeat
            "#{time_ago_in_words(agent.last_heartbeat)} ago"
          else
            "Never"
          end
        end

        td(class: "px-6 py-4 whitespace-nowrap text-sm") do
          a(href: agent_path(agent), class: "text-blue-600 hover:text-blue-900") { "View" }
        end
      end
    end

    def render_health_score(score)
      div(class: "flex items-center") do
        div(class: "flex-1 h-2 bg-gray-200 rounded-full mr-2") do
          score_class = score >= 70 ? "bg-green-500" : (score >= 50 ? "bg-yellow-500" : "bg-red-500")
          div(class: "h-2 rounded-full #{score_class}", style: "width: #{score}%")
        end
        span(class: "text-sm text-gray-700") { "#{score.to_i}%" }
      end
    end

    def render_recent_tasks
      div(class: "bg-white rounded-lg shadow") do
        div(class: "px-6 py-4 border-b border-gray-200") do
          h2(class: "text-xl font-semibold") { "Recent Tasks" }
        end

        div(class: "overflow-x-auto") do
          table(class: "min-w-full divide-y divide-gray-200") do
            thead(class: "bg-gray-50") do
              tr do
                th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "ID" }
                th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Type" }
                th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Status" }
                th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Agent" }
                th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Priority" }
                th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Created" }
              end
            end

            tbody(class: "bg-white divide-y divide-gray-200") do
              @recent_tasks.each do |task|
                render_task_row(task)
              end
            end
          end
        end
      end
    end

    def render_task_row(task)
      tr(class: "hover:bg-gray-50") do
        td(class: "px-6 py-4 whitespace-nowrap text-sm font-mono") { "##{task.id}" }
        td(class: "px-6 py-4 whitespace-nowrap text-sm") { task.task_type }

        td(class: "px-6 py-4 whitespace-nowrap") do
          status_class = case task.status
          when "completed" then "bg-green-100 text-green-800"
          when "running" then "bg-blue-100 text-blue-800"
          when "failed" then "bg-red-100 text-red-800"
          else "bg-gray-100 text-gray-800"
          end

          span(class: "px-2 inline-flex text-xs leading-5 font-semibold rounded-full #{status_class}") do
            task.status
          end
        end

        td(class: "px-6 py-4 whitespace-nowrap text-sm") do
          if task.agent
            a(
              href: agent_path(task.agent),
              class: "text-blue-600 hover:text-blue-900"
            ) { task.agent.name }
          else
            plain "-"
          end
        end

        td(class: "px-6 py-4 whitespace-nowrap text-sm") { task.priority }

        td(class: "px-6 py-4 whitespace-nowrap text-sm text-gray-500") do
          "#{time_ago_in_words(task.created_at)} ago"
        end
      end
    end
  end
end
