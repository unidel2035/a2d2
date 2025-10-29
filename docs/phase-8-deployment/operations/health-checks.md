# DEPLOY-005: Проверки работоспособности и дымовые тесты

**Статус**: Завершено
**Версия**: 1.0
**Последнее обновление**: 2025-10-28

## Обзор

Комплексные процедуры проверки работоспособности и дымового тестирования для платформы A2D2 для обеспечения надежности системы.

## Конечные точки проверки работоспособности

### Проверка работоспособности приложения

```ruby
# app/controllers/health_controller.rb
class HealthController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    checks = {
      database: check_database,
      redis: check_redis,
      storage: check_storage,
      jobs: check_jobs
    }

    status = checks.values.all? { |check| check[:status] == 'ok' } ? 'healthy' : 'unhealthy'
    http_status = status == 'healthy' ? :ok : :service_unavailable

    render json: {
      status: status,
      timestamp: Time.current,
      version: Rails.application.config.version,
      checks: checks
    }, status: http_status
  end

  private

  def check_database
    ActiveRecord::Base.connection.execute('SELECT 1')
    { status: 'ok', latency_ms: measure_latency { ActiveRecord::Base.connection.execute('SELECT 1') } }
  rescue => e
    { status: 'error', message: e.message }
  end

  def check_redis
    Rails.cache.redis.ping
    { status: 'ok', latency_ms: measure_latency { Rails.cache.redis.ping } }
  rescue => e
    { status: 'error', message: e.message }
  end

  def check_storage
    ActiveStorage::Blob.service.exist?('health_check')
    { status: 'ok' }
  rescue => e
    { status: 'error', message: e.message }
  end

  def check_jobs
    queue_size = SolidQueue::Job.pending.count
    { status: 'ok', queue_size: queue_size, warning: queue_size > 1000 }
  rescue => e
    { status: 'error', message: e.message }
  end

  def measure_latency
    start = Time.current
    yield
    ((Time.current - start) * 1000).round(2)
  end
end
```

### Конфигурация маршрутов

```ruby
# config/routes.rb
Rails.application.routes.draw do
  get '/health', to: 'health#index'
  get '/health/ready', to: 'health#ready'     # Readiness probe
  get '/health/live', to: 'health#live'       # Liveness probe
end
```

## Проверки работоспособности Kubernetes

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      containers:
      - name: a2d2
        livenessProbe:
          httpGet:
            path: /health/live
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3

        readinessProbe:
          httpGet:
            path: /health/ready
            port: 3000
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
```

## Дымовые тесты

### Автоматизированный набор дымовых тестов

```ruby
# test/smoke/smoke_test.rb
require 'test_helper'

class SmokeTest < ActiveSupport::TestCase
  def setup
    @base_url = ENV.fetch('SMOKE_TEST_URL', 'http://localhost:3000')
  end

  test "health endpoint responds" do
    response = Net::HTTP.get_response(URI("#{@base_url}/health"))
    assert_equal '200', response.code
    json = JSON.parse(response.body)
    assert_equal 'healthy', json['status']
  end

  test "homepage loads" do
    response = Net::HTTP.get_response(URI(@base_url))
    assert_equal '200', response.code
  end

  test "api authentication works" do
    uri = URI("#{@base_url}/api/v1/status")
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{ENV['API_TOKEN']}"

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end

    assert_includes ['200', '401'], response.code
  end

  test "database is accessible" do
    response = Net::HTTP.get_response(URI("#{@base_url}/health"))
    json = JSON.parse(response.body)
    assert_equal 'ok', json.dig('checks', 'database', 'status')
  end

  test "redis is accessible" do
    response = Net::HTTP.get_response(URI("#{@base_url}/health"))
    json = JSON.parse(response.body)
    assert_equal 'ok', json.dig('checks', 'redis', 'status')
  end

  test "background jobs are processing" do
    response = Net::HTTP.get_response(URI("#{@base_url}/health"))
    json = JSON.parse(response.body)
    assert_equal 'ok', json.dig('checks', 'jobs', 'status')
  end
end
```

Запустите дымовые тесты:

```bash
SMOKE_TEST_URL=https://a2d2.example.com rails test:smoke
```

### Контрольный список ручных дымовых тестов

```markdown
## Post-Deployment Smoke Tests

### Infrastructure
- [ ] Health endpoint returns 200
- [ ] Database connectivity OK
- [ ] Redis connectivity OK
- [ ] Storage accessibility OK
- [ ] Background jobs running

### Core Features
- [ ] Homepage loads
- [ ] Login works
- [ ] Dashboard displays
- [ ] Document upload works
- [ ] API endpoints respond
- [ ] Search functionality works

### Performance
- [ ] Response time < 2s (95th percentile)
- [ ] No 500 errors in logs
- [ ] Memory usage normal
- [ ] CPU usage normal

### Security
- [ ] HTTPS redirect works
- [ ] Security headers present
- [ ] Authentication required
- [ ] No exposed secrets in logs
```

## Скрипты мониторинга

### Непрерывный мониторинг работоспособности

```bash
#!/bin/bash
# File: scripts/monitor-health.sh

ENDPOINT="http://localhost:3000/health"
ALERT_EMAIL="ops@example.com"
CHECK_INTERVAL=30

while true; do
    response=$(curl -s -o /dev/null -w "%{http_code}" "$ENDPOINT")

    if [ "$response" != "200" ]; then
        echo "[$(date)] ALERT: Health check failed with status $response"

        # Send alert
        echo "Health check failed at $(date)" | \
            mail -s "A2D2 Health Check Failed" "$ALERT_EMAIL"

        # Log details
        curl -s "$ENDPOINT" | jq '.' >> /var/log/a2d2/health-failures.log
    else
        echo "[$(date)] OK: Health check passed"
    fi

    sleep "$CHECK_INTERVAL"
done
```

### Комплексная проверка системы

```bash
#!/bin/bash
# File: scripts/system-check.sh

echo "A2D2 System Health Check"
echo "========================"
echo ""

# 1. Application health
echo "1. Application Health:"
curl -s http://localhost:3000/health | jq '.'
echo ""

# 2. Service status
echo "2. Service Status:"
systemctl status a2d2-web --no-pager | head -3
systemctl status a2d2-worker --no-pager | head -3
echo ""

# 3. Database status
echo "3. Database Status:"
sudo -u postgres psql -c "SELECT count(*) as active_connections FROM pg_stat_activity WHERE datname='a2d2_production';"
echo ""

# 4. Redis status
echo "4. Redis Status:"
redis-cli ping
redis-cli info stats | grep total_connections_received
echo ""

# 5. Disk space
echo "5. Disk Space:"
df -h / /var | tail -2
echo ""

# 6. Memory usage
echo "6. Memory Usage:"
free -h
echo ""

# 7. Recent errors
echo "7. Recent Application Errors:"
tail -20 /var/www/a2d2/shared/log/production.log | grep ERROR || echo "No recent errors"
echo ""

# 8. Queue status
echo "8. Background Job Queue:"
cd /var/www/a2d2/current
RAILS_ENV=production bundle exec rails runner "puts \"Pending jobs: #{SolidQueue::Job.pending.count}\""
echo ""

echo "System check complete!"
```

## Бенчмарки производительности

### Нагрузочное тестирование с Apache Bench

```bash
# Simple load test
ab -n 1000 -c 10 http://localhost:3000/

# API endpoint test
ab -n 1000 -c 10 -H "Authorization: Bearer TOKEN" \
    http://localhost:3000/api/v1/documents

# Sustained load test
ab -n 10000 -c 50 -t 60 http://localhost:3000/
```

### Мониторинг времени отклика

```bash
#!/bin/bash
# File: scripts/response-time-check.sh

ENDPOINT="http://localhost:3000/health"
ITERATIONS=100

echo "Running response time check ($ITERATIONS requests)..."

total=0
for i in $(seq 1 $ITERATIONS); do
    time=$(curl -s -w "%{time_total}" -o /dev/null "$ENDPOINT")
    total=$(echo "$total + $time" | bc)

    if [ $((i % 10)) -eq 0 ]; then
        echo "Progress: $i/$ITERATIONS"
    fi
done

average=$(echo "scale=3; $total / $ITERATIONS" | bc)
echo "Average response time: ${average}s"

if (( $(echo "$average > 2.0" | bc -l) )); then
    echo "WARNING: Response time exceeds 2s threshold!"
    exit 1
fi
```

## Конфигурация оповещений

### Правила оповещений Prometheus

```yaml
# prometheus/alert-rules.yml
groups:
  - name: a2d2_health
    rules:
      - alert: HealthCheckFailing
        expr: up{job="a2d2"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "A2D2 health check failing"
          description: "Health endpoint has been down for 1 minute"

      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High error rate detected"

      - alert: SlowResponseTime
        expr: http_request_duration_seconds{quantile="0.95"} > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Response times degraded"

      - alert: HighQueueSize
        expr: solid_queue_pending_jobs > 1000
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Background job queue backing up"
```

## Запланированные проверки работоспособности

### Конфигурация Cron

```bash
# /etc/cron.d/a2d2-health
# Run health check every 5 minutes
*/5 * * * * deploy /var/www/a2d2/scripts/monitor-health.sh >> /var/log/a2d2/health-monitor.log 2>&1

# Run full system check hourly
0 * * * * deploy /var/www/a2d2/scripts/system-check.sh >> /var/log/a2d2/system-check.log 2>&1

# Run response time check every 15 minutes
*/15 * * * * deploy /var/www/a2d2/scripts/response-time-check.sh >> /var/log/a2d2/response-time.log 2>&1
```

## Интеграция с внешним мониторингом

### Интеграция с Datadog

```ruby
# config/initializers/datadog.rb
if Rails.env.production?
  require 'datadog/statsd'

  $statsd = Datadog::Statsd.new('localhost', 8125)

  # Custom health check metric
  Rails.application.config.after_initialize do
    Thread.new do
      loop do
        begin
          health_response = Net::HTTP.get_response(URI('http://localhost:3000/health'))
          status = health_response.code == '200' ? 1 : 0
          $statsd.gauge('a2d2.health', status)
        rescue => e
          $statsd.gauge('a2d2.health', 0)
        end
        sleep 30
      end
    end
  end
end
```

---

**Версия документа**: 1.0
**Последнее обновление**: 2025-10-28
**Сопровождающий**: A2D2 DevOps Team
