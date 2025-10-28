module Analytics
  # ANL-004: Automated insights generation using Analyzer Agent
  class InsightsGenerator
    def initialize(dashboard_id)
      @dashboard = Dashboard.find(dashboard_id)
    end

    def generate_insights
      insights = []

      # Generate insights for each widget
      @dashboard.widgets.each do |widget|
        widget_insights = generate_widget_insights(widget)
        insights.concat(widget_insights)
      end

      # Use Analyzer Agent for advanced insights
      agent_insights = request_agent_insights(insights)

      {
        generated_at: Time.current,
        dashboard_id: @dashboard.id,
        insights: insights,
        agent_insights: agent_insights
      }
    end

    private

    def generate_widget_insights(widget)
      case widget["type"]
      when "metric_chart"
        generate_metric_insights(widget)
      when "process_status"
        generate_process_insights(widget)
      when "agent_performance"
        generate_agent_insights(widget)
      when "integration_health"
        generate_integration_insights(widget)
      else
        []
      end
    end

    def generate_metric_insights(widget)
      metric_name = widget["metric_name"]
      trend = Metric.trend_analysis(metric_name)

      insights = []

      case trend[:trend]
      when :increasing
        insights << {
          type: "trend",
          severity: "info",
          message: "#{metric_name} is increasing. Predicted next value: #{trend[:prediction].round(2)}"
        }
      when :decreasing
        insights << {
          type: "trend",
          severity: "warning",
          message: "#{metric_name} is decreasing. Current trend may require attention."
        }
      end

      insights
    end

    def generate_process_insights(widget)
      failed_count = ProcessExecution.where(status: :failed).where("updated_at >= ?", 24.hours.ago).count
      total_count = ProcessExecution.where("created_at >= ?", 24.hours.ago).count

      insights = []

      if total_count > 0
        failure_rate = (failed_count.to_f / total_count * 100).round(2)

        if failure_rate > 10
          insights << {
            type: "alert",
            severity: "critical",
            message: "Process failure rate is #{failure_rate}% in the last 24 hours. Investigation recommended."
          }
        elsif failure_rate > 5
          insights << {
            type: "alert",
            severity: "warning",
            message: "Process failure rate is #{failure_rate}% in the last 24 hours."
          }
        end
      end

      insights
    end

    def generate_agent_insights(widget)
      offline_agents = Agent.where.not(status: "offline").where("last_heartbeat_at < ?", 10.minutes.ago).count

      insights = []

      if offline_agents > 0
        insights << {
          type: "alert",
          severity: "warning",
          message: "#{offline_agents} agent(s) appear to be offline or unresponsive."
        }
      end

      insights
    end

    def generate_integration_insights(widget)
      failed_integrations = Integration.where(status: :error).count

      insights = []

      if failed_integrations > 0
        insights << {
          type: "alert",
          severity: "critical",
          message: "#{failed_integrations} integration(s) are in error state."
        }
      end

      insights
    end

    def request_agent_insights(basic_insights)
      # Use Analyzer Agent for deeper analysis
      agent = Agent.by_type("Agents::AnalyzerAgent").available.first

      return [] unless agent

      task = agent.agent_tasks.create!(
        task_type: "generate_insights",
        input_data: {
          dashboard_id: @dashboard.id,
          basic_insights: basic_insights,
          metrics_summary: gather_metrics_summary
        },
        priority: 3
      )

      # In production, this would wait for the task to complete
      # For now, return placeholder
      []
    end

    def gather_metrics_summary
      {
        total_processes: Process.count,
        active_processes: Process.active.count,
        total_agents: Agent.count,
        active_agents: Agent.active.count,
        total_integrations: Integration.count,
        active_integrations: Integration.active_integrations.count
      }
    end
  end
end
