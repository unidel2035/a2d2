# frozen_string_literal: true

module Agents
  class ShowView < ApplicationComponent
    def initialize(agent:, tasks:, registry_entry: nil)
      @agent = agent
      @tasks = tasks
      @registry_entry = registry_entry
    end

    def view_template
      div(class: "container mx-auto px-4 py-8") do
        render_back_link
        render_agent_details
        render_registry_info if @registry_entry
        render_recent_tasks
      end
    end

    private

    def render_back_link
      div(class: "mb-6") do
        a(
          href: agents_path,
          class: "text-blue-600 hover:text-blue-900"
        ) { "← Back to Agents" }
      end
    end

    def render_agent_details
      div(class: "bg-white rounded-lg shadow mb-6") do
        div(class: "px-6 py-4 border-b border-gray-200") do
          h1(class: "text-2xl font-bold") { @agent.name }
        end

        div(class: "px-6 py-6") do
          div(class: "grid grid-cols-1 md:grid-cols-2 gap-6") do
            render_detail_field("Agent Type", @agent.agent_type)
            render_status_field
            render_health_score_field
            render_heartbeat_field
            render_version_field
            render_endpoint_field
            render_capabilities_field
          end
        end
      end
    end

    def render_detail_field(label, value)
      div do
        h3(class: "text-sm font-medium text-gray-500 mb-1") { label }
        p(class: "text-lg") { value || "N/A" }
      end
    end

    def render_status_field
      div do
        h3(class: "text-sm font-medium text-gray-500 mb-1") { "Status" }
        status_class = case @agent.status
        when "idle" then "bg-green-100 text-green-800"
        when "busy" then "bg-yellow-100 text-yellow-800"
        when "failed" then "bg-red-100 text-red-800"
        else "bg-gray-100 text-gray-800"
        end

        span(class: "px-3 py-1 inline-flex text-sm font-semibold rounded-full #{status_class}") do
          @agent.status
        end
      end
    end

    def render_health_score_field
      div do
        h3(class: "text-sm font-medium text-gray-500 mb-1") { "Health Score" }
        div(class: "flex items-center") do
          div(class: "flex-1 h-4 bg-gray-200 rounded-full mr-3") do
            score_class = @agent.health_score >= 70 ? "bg-green-500" : (@agent.health_score >= 50 ? "bg-yellow-500" : "bg-red-500")
            div(class: "h-4 rounded-full #{score_class}", style: "width: #{@agent.health_score}%")
          end
          span(class: "text-lg font-semibold") { "#{@agent.health_score.to_i}%" }
        end
      end
    end

    def render_heartbeat_field
      div do
        h3(class: "text-sm font-medium text-gray-500 mb-1") { "Last Heartbeat" }
        p(class: "text-lg") do
          if @agent.last_heartbeat
            "#{time_ago_in_words(@agent.last_heartbeat)} ago"
          else
            "Never"
          end
        end
      end
    end

    def render_version_field
      render_detail_field("Version", @agent.version)
    end

    def render_endpoint_field
      div do
        h3(class: "text-sm font-medium text-gray-500 mb-1") { "Endpoint" }
        p(class: "text-lg font-mono text-sm") { @agent.endpoint || "N/A" }
      end
    end

    def render_capabilities_field
      div(class: "md:col-span-2") do
        h3(class: "text-sm font-medium text-gray-500 mb-2") { "Capabilities" }
        if @agent.capabilities.present?
          div(class: "flex flex-wrap gap-2") do
            @agent.capabilities.each do |cap|
              span(class: "px-3 py-1 bg-blue-100 text-blue-800 rounded-lg text-sm") { cap }
            end
          end
        else
          p(class: "text-gray-400") { "No capabilities defined" }
        end
      end
    end

    def render_registry_info
      div(class: "bg-white rounded-lg shadow mb-6") do
        div(class: "px-6 py-4 border-b border-gray-200") do
          h2(class: "text-xl font-semibold") { "Registry Information" }
        end

        div(class: "px-6 py-6") do
          div(class: "grid grid-cols-1 md:grid-cols-3 gap-6") do
            render_detail_field("Registration Status", @registry_entry.registration_status)
            render_detail_field("Consecutive Failures", @registry_entry.consecutive_failures.to_s)

            div do
              h3(class: "text-sm font-medium text-gray-500 mb-1") { "Last Health Check" }
              p(class: "text-lg") do
                if @registry_entry.last_health_check
                  "#{time_ago_in_words(@registry_entry.last_health_check)} ago"
                else
                  "Never"
                end
              end
            end
          end
        end
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
                th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Priority" }
                th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Created" }
                th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Duration" }
              end
            end

            tbody(class: "bg-white divide-y divide-gray-200") do
              if @tasks.any?
                @tasks.each do |task|
                  render_task_row(task)
                end
              end
            end
          end

          if @tasks.empty?
            div(class: "px-6 py-8 text-center text-gray-500") do
              "No tasks yet"
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

        td(class: "px-6 py-4 whitespace-nowrap text-sm") { task.priority }

        td(class: "px-6 py-4 whitespace-nowrap text-sm text-gray-500") do
          "#{time_ago_in_words(task.created_at)} ago"
        end

        td(class: "px-6 py-4 whitespace-nowrap text-sm text-gray-500") do
          task.duration ? "#{task.duration.round(2)}s" : "-"
        end
      end
    end
  end
end
