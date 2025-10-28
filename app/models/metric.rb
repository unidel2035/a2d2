class Metric < ApplicationRecord
  # Validations
  validates :name, presence: true
  validates :metric_type, presence: true
  validates :value, presence: true
  validates :recorded_at, presence: true

  # Scopes
  scope :by_name, ->(name) { where(name: name) }
  scope :by_type, ->(type) { where(metric_type: type) }
  scope :recent, -> { order(recorded_at: :desc) }
  scope :in_range, ->(start_time, end_time) { where(recorded_at: start_time..end_time) }

  # Metric types
  METRIC_TYPES = %w[counter gauge histogram].freeze
  validates :metric_type, inclusion: { in: METRIC_TYPES }

  # Class methods for ANL-001: Automatic metric collection
  class << self
    def record_counter(name, value = 1, labels: {}, metadata: {})
      create!(
        name: name,
        metric_type: "counter",
        value: value,
        labels: labels,
        metadata: metadata,
        recorded_at: Time.current
      )
    end

    def record_gauge(name, value, labels: {}, metadata: {})
      create!(
        name: name,
        metric_type: "gauge",
        value: value,
        labels: labels,
        metadata: metadata,
        recorded_at: Time.current
      )
    end

    def record_histogram(name, value, labels: {}, metadata: {})
      create!(
        name: name,
        metric_type: "histogram",
        value: value,
        labels: labels,
        metadata: metadata,
        recorded_at: Time.current
      )
    end

    # ANL-003: Predictive analytics
    def trend_analysis(name, period: 7.days)
      metrics = by_name(name)
                .in_range(period.ago, Time.current)
                .order(:recorded_at)

      return {} if metrics.empty?

      values = metrics.pluck(:value)
      {
        min: values.min,
        max: values.max,
        avg: values.sum / values.size.to_f,
        trend: calculate_trend(values),
        prediction: predict_next_value(values)
      }
    end

    private

    def calculate_trend(values)
      return :stable if values.size < 2

      recent = values.last(values.size / 2)
      earlier = values.first(values.size / 2)

      recent_avg = recent.sum / recent.size.to_f
      earlier_avg = earlier.sum / earlier.size.to_f

      if recent_avg > earlier_avg * 1.1
        :increasing
      elsif recent_avg < earlier_avg * 0.9
        :decreasing
      else
        :stable
      end
    end

    def predict_next_value(values)
      return values.last if values.size < 2

      # Simple linear prediction
      recent_values = values.last(5)
      avg_change = (recent_values.last - recent_values.first) / (recent_values.size - 1).to_f
      recent_values.last + avg_change
    end
  end
end
