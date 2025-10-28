module Agents
  class AnalyzerAgent < Agent
    def initialize(attributes = {})
      super
      self.type ||= "Agents::AnalyzerAgent"
      self.capabilities ||= {
        statistical_analysis: true,
        anomaly_detection: true,
        data_profiling: true,
        trend_analysis: true,
        insights_generation: true
      }
    end

    def execute(task)
      data = task.input_data["data"]
      analysis_type = task.input_data["analysis_type"] || "comprehensive"

      result = case analysis_type
      when "statistical"
        perform_statistical_analysis(data)
      when "anomaly"
        detect_anomalies(data)
      when "profile"
        profile_data(data)
      when "trend"
        analyze_trends(data)
      when "comprehensive"
        {
          statistical: perform_statistical_analysis(data),
          anomalies: detect_anomalies(data),
          profile: profile_data(data),
          trends: analyze_trends(data),
          insights: generate_insights(data)
        }
      else
        { error: "Unknown analysis type: #{analysis_type}" }
      end

      result
    end

    private

    def perform_statistical_analysis(data)
      return { error: "Data must be an array" } unless data.is_a?(Array)

      numeric_data = data.select { |v| v.is_a?(Numeric) }
      return { error: "No numeric data found" } if numeric_data.empty?

      sorted = numeric_data.sort
      {
        count: numeric_data.size,
        sum: numeric_data.sum,
        mean: numeric_data.sum.to_f / numeric_data.size,
        median: calculate_median(sorted),
        min: sorted.first,
        max: sorted.last,
        range: sorted.last - sorted.first,
        std_dev: calculate_std_dev(numeric_data)
      }
    end

    def detect_anomalies(data)
      return { error: "Data must be an array" } unless data.is_a?(Array)

      numeric_data = data.select { |v| v.is_a?(Numeric) }
      return { anomalies: [] } if numeric_data.size < 3

      mean = numeric_data.sum.to_f / numeric_data.size
      std_dev = calculate_std_dev(numeric_data)

      # Detect outliers using Z-score (values > 2 standard deviations)
      anomalies = numeric_data.each_with_index.select do |value, _index|
        z_score = ((value - mean) / std_dev).abs
        z_score > 2
      end.map { |value, index| { index: index, value: value } }

      {
        anomalies: anomalies,
        count: anomalies.size,
        threshold: mean + (2 * std_dev)
      }
    end

    def profile_data(data)
      return { error: "Data must be an array" } unless data.is_a?(Array)

      {
        total_records: data.size,
        data_types: data.group_by { |v| v.class.name }.transform_values(&:count),
        null_count: data.count(&:nil?),
        unique_count: data.uniq.size,
        duplicate_count: data.size - data.uniq.size
      }
    end

    def analyze_trends(data)
      return { error: "Data must be an array of numeric values" } unless data.is_a?(Array)

      numeric_data = data.select { |v| v.is_a?(Numeric) }
      return { error: "Insufficient data for trend analysis" } if numeric_data.size < 3

      # Simple linear regression to detect trend
      n = numeric_data.size
      x_values = (0...n).to_a
      y_values = numeric_data

      x_mean = x_values.sum.to_f / n
      y_mean = y_values.sum.to_f / n

      numerator = x_values.zip(y_values).sum { |x, y| (x - x_mean) * (y - y_mean) }
      denominator = x_values.sum { |x| (x - x_mean)**2 }

      slope = denominator.zero? ? 0 : numerator / denominator
      intercept = y_mean - (slope * x_mean)

      trend = if slope > 0.1
        "increasing"
      elsif slope < -0.1
        "decreasing"
      else
        "stable"
      end

      {
        trend: trend,
        slope: slope.round(4),
        intercept: intercept.round(4),
        direction: slope.positive? ? "upward" : "downward"
      }
    end

    def generate_insights(data)
      stats = perform_statistical_analysis(data)
      anomalies = detect_anomalies(data)
      trends = analyze_trends(data)

      llm = Llm::Client.new(route: :fast)
      messages = [
        {
          role: "system",
          content: "You are a data analyst. Provide concise insights based on the statistical analysis."
        },
        {
          role: "user",
          content: "Analyze this data summary and provide 3-5 key insights:\n\nStatistics: #{stats.to_json}\nAnomalies: #{anomalies.to_json}\nTrends: #{trends.to_json}"
        }
      ]

      response = llm.chat(messages: messages, max_tokens: 500)
      response[:content] || "Unable to generate insights"
    end

    def calculate_median(sorted_array)
      n = sorted_array.size
      if n.odd?
        sorted_array[n / 2]
      else
        (sorted_array[n / 2 - 1] + sorted_array[n / 2]) / 2.0
      end
    end

    def calculate_std_dev(data)
      mean = data.sum.to_f / data.size
      variance = data.sum { |v| (v - mean)**2 } / data.size
      Math.sqrt(variance)
    end
  end
end
