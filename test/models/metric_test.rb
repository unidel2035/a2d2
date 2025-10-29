require "test_helper"

class MetricTest < ActiveSupport::TestCase
  test "should create counter metric" do
    metric = Metric.record_counter("test.counter", 5)

    assert metric.persisted?
    assert_equal "test.counter", metric.name
    assert_equal "counter", metric.metric_type
    assert_equal 5, metric.value
  end

  test "should create gauge metric" do
    metric = Metric.record_gauge("test.gauge", 42.5)

    assert metric.persisted?
    assert_equal "test.gauge", metric.name
    assert_equal "gauge", metric.metric_type
    assert_equal 42.5, metric.value
  end

  test "should create histogram metric" do
    metric = Metric.record_histogram("test.histogram", 123.45)

    assert metric.persisted?
    assert_equal "histogram", metric.metric_type
  end

  test "should record metrics with labels" do
    metric = Metric.record_counter(
      "http.requests",
      1,
      labels: { method: "GET", status: "200" }
    )

    assert_equal "GET", metric.labels["method"]
    assert_equal "200", metric.labels["status"]
  end

  test "should perform trend analysis" do
    # Create increasing trend
    10.times do |i|
      Metric.create!(
        name: "test.trend",
        metric_type: "gauge",
        value: i * 10,
        recorded_at: i.days.ago
      )
    end

    analysis = Metric.trend_analysis("test.trend", period: 14.days)

    assert_includes [:increasing, :decreasing, :stable], analysis[:trend]
    assert analysis[:min] >= 0
    assert analysis[:max] > analysis[:min]
    assert analysis[:avg] > 0
    assert_not_nil analysis[:prediction]
  end

  test "should scope by name" do
    Metric.record_counter("metric.a", 1)
    Metric.record_counter("metric.b", 2)

    metrics_a = Metric.by_name("metric.a")
    assert_equal 1, metrics_a.count
    assert_equal "metric.a", metrics_a.first.name
  end

  test "should scope by time range" do
    old_metric = Metric.create!(
      name: "test",
      metric_type: "gauge",
      value: 1,
      recorded_at: 10.days.ago
    )

    recent_metric = Metric.create!(
      name: "test",
      metric_type: "gauge",
      value: 2,
      recorded_at: 1.hour.ago
    )

    recent_metrics = Metric.in_range(2.days.ago, Time.current)

    assert_includes recent_metrics, recent_metric
    assert_not_includes recent_metrics, old_metric
  end
end
