class Dashboard < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :name, presence: true
  validates :refresh_interval, numericality: { greater_than: 0 }

  # Scopes
  scope :public_dashboards, -> { where(is_public: true) }
  scope :private_dashboards, -> { where(is_public: false) }
  scope :recent, -> { order(created_at: :desc) }

  # ANL-002: Customizable dashboards
  def add_widget(widget_config)
    current_widgets = widgets || []
    current_widgets << widget_config
    update!(widgets: current_widgets)
  end

  def remove_widget(widget_id)
    current_widgets = widgets || []
    current_widgets.reject! { |w| w["id"] == widget_id }
    update!(widgets: current_widgets)
  end

  def update_widget(widget_id, new_config)
    current_widgets = widgets || []
    widget = current_widgets.find { |w| w["id"] == widget_id }
    widget.merge!(new_config) if widget
    update!(widgets: current_widgets)
  end

  # ANL-007: Drill-down capabilities
  def get_widget_data(widget_id, params = {})
    widget = widgets.find { |w| w["id"] == widget_id }
    return nil unless widget

    case widget["type"]
    when "metric_chart"
      fetch_metric_data(widget, params)
    when "process_status"
      fetch_process_status(widget, params)
    when "agent_performance"
      fetch_agent_performance(widget, params)
    when "integration_health"
      fetch_integration_health(widget, params)
    else
      {}
    end
  end

  private

  def fetch_metric_data(widget, params)
    metric_name = widget["metric_name"]
    time_range = params[:time_range] || 24.hours

    Metric.by_name(metric_name)
          .in_range(time_range.ago, Time.current)
          .order(:recorded_at)
          .pluck(:recorded_at, :value)
  end

  def fetch_process_status(widget, params)
    ProcessExecution.group(:status).count
  end

  def fetch_agent_performance(widget, params)
    Agent.group(:type, :status).count
  end

  def fetch_integration_health(widget, params)
    Integration.group(:integration_type, :status).count
  end
end
