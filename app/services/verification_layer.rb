class VerificationLayer
  include Singleton

  QUALITY_THRESHOLDS = {
    high: 90,
    medium: 70,
    low: 50
  }.freeze

  # Main verification method
  def verify_task_result(task_id, verification_types: [:schema, :business_rules])
    task = AgentTask.find(task_id)

    unless task.completed?
      Rails.logger.warn "Cannot verify task #{task_id}: not completed"
      return false
    end

    overall_score = 0
    verification_count = 0

    verification_types.each do |type|
      result = perform_verification(task, type)
      overall_score += result[:score]
      verification_count += 1

      create_verification_log(task, type, result)
    end

    average_score = verification_count > 0 ? overall_score / verification_count : 0

    # Handle low quality results
    if average_score < QUALITY_THRESHOLDS[:low]
      handle_low_quality_result(task, average_score)
    end

    {
      task_id: task.id,
      overall_score: average_score,
      quality_level: determine_quality_level(average_score),
      verifications: verification_types.size,
      needs_reassignment: average_score < QUALITY_THRESHOLDS[:low]
    }
  end

  # Individual verification methods
  def verify_schema(task)
    score = 100
    issues = []

    # Check if result has required fields
    required_fields = task.metadata.dig('verification', 'required_fields') || []
    required_fields.each do |field|
      unless task.result.key?(field)
        score -= 20
        issues << { field: field, issue: 'missing_required_field' }
      end
    end

    {
      type: :schema,
      score: [score, 0].max,
      status: score >= QUALITY_THRESHOLDS[:medium] ? 'passed' : 'failed',
      issues: issues,
      data: { required_fields: required_fields, found_fields: task.result.keys }
    }
  end

  def verify_business_rules(task)
    score = 100
    issues = []

    # Validate based on business rules defined in task metadata
    rules = task.metadata.dig('verification', 'business_rules') || []

    rules.each do |rule|
      unless validate_rule(task.result, rule)
        score -= 15
        issues << { rule: rule, issue: 'business_rule_violation' }
      end
    end

    {
      type: :business_rules,
      score: [score, 0].max,
      status: score >= QUALITY_THRESHOLDS[:medium] ? 'passed' : 'failed',
      issues: issues,
      data: { rules_checked: rules.size, violations: issues.size }
    }
  end

  def verify_data_quality(task)
    score = 100
    issues = []

    result = task.result

    # Check for null/empty values
    if result.values.any?(&:nil?)
      score -= 10
      issues << { issue: 'contains_null_values' }
    end

    # Check data types
    expected_types = task.metadata.dig('verification', 'expected_types') || {}
    expected_types.each do |key, expected_type|
      actual_value = result[key]
      next unless actual_value

      unless matches_type?(actual_value, expected_type)
        score -= 15
        issues << { field: key, expected: expected_type, actual: actual_value.class.to_s }
      end
    end

    {
      type: :data_quality,
      score: [score, 0].max,
      status: score >= QUALITY_THRESHOLDS[:medium] ? 'passed' : 'failed',
      issues: issues,
      data: { total_fields: result.size, issues_found: issues.size }
    }
  end

  def verify_completeness(task)
    score = 100
    issues = []

    # Check if result is empty
    if task.result.empty?
      score = 0
      issues << { issue: 'empty_result' }
    end

    # Check expected result size
    min_size = task.metadata.dig('verification', 'min_result_size')
    if min_size && task.result.size < min_size
      score -= 30
      issues << { issue: 'insufficient_data', expected: min_size, actual: task.result.size }
    end

    {
      type: :completeness,
      score: [score, 0].max,
      status: score >= QUALITY_THRESHOLDS[:medium] ? 'passed' : 'failed',
      issues: issues,
      data: { result_size: task.result.size }
    }
  end

  def verify_performance(task)
    score = 100
    issues = []

    # Check task duration
    if task.duration
      max_duration = task.metadata.dig('verification', 'max_duration') || 300.seconds

      if task.duration > max_duration
        score -= 20
        issues << { issue: 'exceeded_time_limit', duration: task.duration, max: max_duration }
      end
    end

    {
      type: :performance,
      score: [score, 0].max,
      status: score >= QUALITY_THRESHOLDS[:medium] ? 'passed' : 'failed',
      issues: issues,
      data: { duration: task.duration }
    }
  end

  # Quality reporting
  def generate_quality_report(agent_id: nil, time_range: 24.hours)
    logs = VerificationLog.where('created_at > ?', time_range.ago)
    logs = logs.where(agent_id: agent_id) if agent_id

    {
      total_verifications: logs.count,
      passed: logs.passed.count,
      failed: logs.failed.count,
      warnings: logs.warning.count,
      average_quality_score: logs.average(:quality_score).to_f.round(2),
      high_quality: logs.high_quality.count,
      low_quality: logs.low_quality.count,
      auto_reassignments: logs.where(auto_reassigned: true).count,
      by_type: logs.group(:verification_type).count,
      time_range: time_range
    }
  end

  def get_agent_quality_metrics(agent_id)
    agent = Agent.find(agent_id)
    logs = agent.verification_logs.where('created_at > ?', 7.days.ago)

    {
      agent_id: agent.id,
      agent_name: agent.name,
      total_verifications: logs.count,
      average_score: logs.average(:quality_score).to_f.round(2),
      pass_rate: calculate_pass_rate(logs),
      high_quality_rate: calculate_high_quality_rate(logs),
      trend: calculate_quality_trend(agent_id)
    }
  end

  private

  def perform_verification(task, type)
    case type
    when :schema
      verify_schema(task)
    when :business_rules
      verify_business_rules(task)
    when :data_quality
      verify_data_quality(task)
    when :completeness
      verify_completeness(task)
    when :performance
      verify_performance(task)
    else
      { type: type, score: 0, status: 'failed', issues: ['unknown_verification_type'], data: {} }
    end
  end

  def create_verification_log(task, type, result)
    VerificationLog.create!(
      agent_task: task,
      agent: task.agent,
      verification_type: type.to_s,
      status: result[:status],
      quality_score: result[:score],
      verification_data: result[:data],
      issues_found: result[:issues]
    )
  rescue StandardError => e
    Rails.logger.error "Failed to create verification log: #{e.message}"
  end

  def handle_low_quality_result(task, score)
    Rails.logger.warn "Low quality result detected for task #{task.id}: score #{score}"

    # Create verification log entry
    log = VerificationLog.create!(
      agent_task: task,
      agent: task.agent,
      verification_type: 'overall',
      status: 'failed',
      quality_score: score,
      verification_data: {},
      issues_found: [{ issue: 'overall_low_quality', score: score }]
    )

    # Auto-reassign if score is too low
    if score < QUALITY_THRESHOLDS[:low]
      log.create_reassignment_task!
    end
  end

  def determine_quality_level(score)
    return :high if score >= QUALITY_THRESHOLDS[:high]
    return :medium if score >= QUALITY_THRESHOLDS[:medium]
    return :low if score >= QUALITY_THRESHOLDS[:low]
    :very_low
  end

  def validate_rule(result, rule)
    # Simple rule validation - can be extended
    field = rule['field']
    operator = rule['operator']
    value = rule['value']

    return true unless result.key?(field)

    actual_value = result[field]

    case operator
    when '=='
      actual_value == value
    when '!='
      actual_value != value
    when '>'
      actual_value.to_f > value.to_f
    when '<'
      actual_value.to_f < value.to_f
    when 'contains'
      actual_value.to_s.include?(value.to_s)
    else
      true
    end
  end

  def matches_type?(value, expected_type)
    case expected_type
    when 'string'
      value.is_a?(String)
    when 'integer'
      value.is_a?(Integer)
    when 'float'
      value.is_a?(Float) || value.is_a?(Integer)
    when 'boolean'
      value.is_a?(TrueClass) || value.is_a?(FalseClass)
    when 'array'
      value.is_a?(Array)
    when 'hash'
      value.is_a?(Hash)
    else
      true
    end
  end

  def calculate_pass_rate(logs)
    return 0 if logs.empty?
    (logs.passed.count.to_f / logs.count * 100).round(2)
  end

  def calculate_high_quality_rate(logs)
    return 0 if logs.empty?
    (logs.high_quality.count.to_f / logs.count * 100).round(2)
  end

  def calculate_quality_trend(agent_id)
    # Compare last 24 hours vs previous 24 hours
    recent = VerificationLog.where(agent_id: agent_id).where('created_at > ?', 24.hours.ago).average(:quality_score).to_f
    previous = VerificationLog.where(agent_id: agent_id).where('created_at BETWEEN ? AND ?', 48.hours.ago, 24.hours.ago).average(:quality_score).to_f

    return 'stable' if previous.zero?

    diff = recent - previous
    return 'improving' if diff > 5
    return 'declining' if diff < -5
    'stable'
  end
end
