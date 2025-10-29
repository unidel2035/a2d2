class MetricCollectionJob < ApplicationJob
  queue_as :default

  # ANL-001: Automatic metric collection
  def perform
    collect_system_metrics
    collect_process_metrics
    collect_agent_metrics
    collect_integration_metrics
    collect_robot_metrics
  end

  private

  def collect_system_metrics
    # Collect basic system metrics
    Metric.record_gauge("users.total", User.count)
    Metric.record_gauge("users.active_operators", User.active_operators.count)
    Metric.record_gauge("documents.total", Document.count)
    Metric.record_gauge("documents.active", Document.active.count)
  end

  def collect_process_metrics
    # Collect process-related metrics
    Metric.record_gauge("processes.total", Process.count)
    Metric.record_gauge("processes.active", Process.active.count)
    Metric.record_gauge("process_executions.pending", ProcessExecution.where(status: :pending).count)
    Metric.record_gauge("process_executions.running", ProcessExecution.where(status: :running).count)
    Metric.record_gauge("process_executions.completed_today", ProcessExecution.where(status: :completed).where("completed_at >= ?", 24.hours.ago).count)
    Metric.record_gauge("process_executions.failed_today", ProcessExecution.where(status: :failed).where("updated_at >= ?", 24.hours.ago).count)
  end

  def collect_agent_metrics
    # Collect agent-related metrics
    Agent.group(:type).count.each do |type, count|
      Metric.record_gauge("agents.by_type", count, labels: { type: type })
    end

    Agent.group(:status).count.each do |status, count|
      Metric.record_gauge("agents.by_status", count, labels: { status: status })
    end

    AgentTask.where("created_at >= ?", 1.hour.ago).group(:status).count.each do |status, count|
      Metric.record_counter("agent_tasks.last_hour", count, labels: { status: status })
    end
  end

  def collect_integration_metrics
    # Collect integration-related metrics
    Integration.group(:integration_type, :status).count.each do |(type, status), count|
      Metric.record_gauge("integrations.status", count, labels: { type: type, status: status })
    end

    # Integration success rate
    Integration.find_each do |integration|
      success_rate = integration.success_rate
      Metric.record_gauge("integration.success_rate", success_rate, labels: { integration_id: integration.id, name: integration.name })
    end
  end

  def collect_robot_metrics
    # Collect robot-related metrics
    Robot.group(:status).count.each do |status, count|
      Metric.record_gauge("robots.by_status", count, labels: { status: status })
    end

    Metric.record_gauge("robots.needs_maintenance", Robot.needs_maintenance.count)
    Metric.record_gauge("tasks.planned", Task.where(status: :planned).count)
    Metric.record_gauge("tasks.in_progress", Task.where(status: :in_progress).count)
    Metric.record_gauge("tasks.completed_today", Task.where(status: :completed).where("actual_end >= ?", 24.hours.ago).count)
  end
end
