# Мониторинг и логирование

**Версия**: 1.0
**Статус**: Документировано
**Дата**: 28 октября 2025

## 📋 Содержание

1. [Architecture Overview](#architecture-overview)
2. [Application Performance Monitoring](#application-performance-monitoring)
3. [Infrastructure Monitoring](#infrastructure-monitoring)
4. [Centralized Logging](#centralized-logging)
5. [Alerting и Notifications](#alerting-и-notifications)
6. [Dashboards и KPIs](#dashboards-и-kpis)

## Architecture Overview

```
┌──────────────────────────────────────────────────────────┐
│                   Application Logs                        │
│            (Puma, Rails, Background Jobs)                 │
└────────────────┬─────────────────────────────────────────┘
                 │
        ┌────────▼─────────┐
        │   Log Collector  │
        │    (Fluent-bit)  │
        └────────┬─────────┘
                 │
        ┌────────▼──────────┐
        │  Centralized      │
        │  Logging System   │
        │  (Loki/ELK)       │
        └────────┬──────────┘
                 │
    ┌────────────┼────────────┐
    │            │            │
    ▼            ▼            ▼
 Grafana    Elasticsearch  S3 Archive
 (Logs)     (Long-term)    (Compliance)

┌──────────────────────────────────────────────────────────┐
│              Infrastructure Metrics                       │
│     (CPU, Memory, Disk, Network from Nodes)              │
└────────────────┬─────────────────────────────────────────┘
                 │
        ┌────────▼──────────┐
        │   Prometheus      │
        │   (Scraper)       │
        └────────┬──────────┘
                 │
            ┌────▼────┐
            │ Grafana  │
            │(Metrics) │
            └────┬─────┘
                 │
        ┌────────▼──────────┐
        │   Alert Manager   │
        └────────┬──────────┘
                 │
    ┌────────────┼──────────────┐
    │            │              │
    ▼            ▼              ▼
  Email       Slack         PagerDuty
```

## Application Performance Monitoring

### MON-001: APM (Application Performance Monitoring)

#### Ruby APM Gems

```ruby
# Gemfile
group :production do
  gem 'newrelic_rpm'  # or
  gem 'datadog'       # or
  gem 'elastic-apm'   # or
  gem 'honeycomb-beeline'
end
```

#### New Relic конфигурация

```yaml
# config/newrelic.yml
common: &default_settings
  license_key: <%= ENV['NEW_RELIC_LICENSE_KEY'] %>
  app_name: <%= ENV['NEW_RELIC_APP_NAME'] || 'A2D2' %>
  monitor_mode: true
  log_level: info

production:
  <<: *default_settings
  monitor_mode: true
  transaction_tracer:
    enabled: true
    transaction_threshold: 2.0
    top_n: 20

  error_collector:
    enabled: true
    capture_source_context: true

  rum:
    enabled: true

  thread_profiler:
    enabled: true
```

#### Custom Metrics

```ruby
# lib/metrics/performance_tracker.rb
class PerformanceTracker
  def self.track_database_query(query_name, duration)
    NewRelic::Agent.record_custom_metric(
      "Custom/Database/#{query_name}",
      duration
    )
  end

  def self.track_api_call(endpoint, response_time, status)
    NewRelic::Agent.record_custom_metric(
      "Custom/API/#{endpoint}/#{status}",
      response_time
    )
  end

  def self.track_background_job(job_name, duration, status)
    NewRelic::Agent.record_custom_metric(
      "Custom/Job/#{job_name}/#{status}",
      duration
    )
  end
end
```

#### Key metrics to track

- **Response Time**: p50, p90, p95, p99
- **Error Rate**: % of failed requests
- **Throughput**: Requests per second
- **Database Time**: % of total request time
- **External API Time**: 3rd party service latencies
- **Background Job Performance**: Queue depth, processing time
- **Memory Usage**: Heap size, GC time
- **Slow Transactions**: Top 10 slowest endpoints

## Infrastructure Monitoring

### MON-002: Infrastructure Monitoring

#### Prometheus конфигурация

```yaml
# monitoring/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    environment: production
    cluster: main

scrape_configs:
  # Node Exporter (System metrics)
  - job_name: 'node'
    static_configs:
      - targets: ['node1:9100', 'node2:9100', 'node3:9100']

  # PostgreSQL Exporter
  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres:9187']
    scrape_interval: 30s

  # Redis Exporter
  - job_name: 'redis'
    static_configs:
      - targets: ['redis:9121']
    scrape_interval: 30s

  # Nginx Exporter
  - job_name: 'nginx'
    static_configs:
      - targets: ['nginx:9113']

  # Rails Application
  - job_name: 'rails'
    static_configs:
      - targets: ['web1:3000', 'web2:3000', 'web3:3000']
    metrics_path: '/metrics'
```

#### Prometheus docker-compose

```yaml
services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - ./monitoring/alert-rules.yml:/etc/prometheus/alert-rules.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=30d'
    environment:
      TZ: UTC

  node_exporter:
    image: prom/node-exporter:latest
    ports:
      - "9100:9100"
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--path.rootfs=/rootfs'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      GF_SECURITY_ADMIN_PASSWORD: ${GRAFANA_ADMIN_PASSWORD}
      GF_USERS_ALLOW_SIGN_UP: 'false'
      GF_INSTALL_PLUGINS: 'redis-datasource'
    volumes:
      - grafana_data:/var/lib/grafana
      - ./monitoring/grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./monitoring/grafana/datasources:/etc/grafana/provisioning/datasources

volumes:
  prometheus_data:
  grafana_data:
```

#### Key infrastructure metrics

```promql
# CPU usage
node_cpu_seconds_total

# Memory usage
node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes

# Disk usage
node_filesystem_avail_bytes / node_filesystem_size_bytes

# Network I/O
rate(node_network_transmit_bytes_total[5m])
rate(node_network_receive_bytes_total[5m])

# PostgreSQL connections
pg_stat_activity_count

# Redis memory
redis_memory_used_bytes

# Nginx requests
rate(nginx_http_requests_total[5m])
```

## Centralized Logging

### MON-003: Centralized Logging System

#### Loki + Promtail Setup

```yaml
# monitoring/loki/loki-config.yml
auth_enabled: false

ingester:
  chunk_idle_period: 3m
  chunk_retain_period: 1m
  max_chunk_age: 1h
  chunk_encoding: snappy

limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h

schema_config:
  configs:
    - from: 2023-01-01
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

server:
  http_listen_port: 3100
  log_level: info

storage_config:
  boltdb_shipper:
    active_index_directory: /loki/boltdb-shipper-active
    shared_store: filesystem
  filesystem:
    directory: /loki/chunks

retention_config:
  enabled: true
  max_look_back_period: 0s
  delete_request_store: filesystem
```

#### Promtail Config (Log shipper)

```yaml
# monitoring/promtail/promtail-config.yml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  # Rails application logs
  - job_name: rails
    static_configs:
      - targets:
          - localhost
        labels:
          job: rails
          __path__: /rails/log/production.log

  # Nginx access logs
  - job_name: nginx
    static_configs:
      - targets:
          - localhost
        labels:
          job: nginx
          __path__: /var/log/nginx/access.log

  # PostgreSQL logs
  - job_name: postgres
    static_configs:
      - targets:
          - localhost
        labels:
          job: postgres
          __path__: /var/log/postgresql/*.log

  # System logs
  - job_name: system
    static_configs:
      - targets:
          - localhost
        labels:
          job: system
          __path__: /var/log/syslog
```

#### Rails Logging Конфигурация

```ruby
# config/environments/production.rb

config.log_level = :info

# Structured logging with JSON
config.log_formatter = ->(severity, datetime, progname, msg) {
  log_hash = {
    timestamp: datetime.iso8601,
    level: severity,
    message: msg.to_s,
    program: progname,
    hostname: Socket.gethostname,
    environment: Rails.env
  }

  JSON.generate(log_hash) + "\n"
}

# Log to both file and stdout
config.logger = ActiveSupport::TaggedLogging.new(
  ActiveSupport::Logger.new(
    [
      STDOUT,
      File.open(Rails.root.join('log', "#{Rails.env}.log"), 'a')
    ]
  )
)

# Log database queries (for debugging)
if ENV['LOG_DATABASE_QUERIES'] == 'true'
  config.active_record.logger = Rails.logger
end
```

## Alerting и Notifications

### MON-004: Alerting Rules

```yaml
# monitoring/prometheus/alert-rules.yml
groups:
  - name: application
    interval: 30s
    rules:
      # High error rate
      - alert: HighErrorRate
        expr: rate(rails_http_requests_total{status=~"5.."}[5m]) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is above 5%"

      # High response time
      - alert: HighResponseTime
        expr: histogram_quantile(0.95, rate(rails_http_request_duration_seconds_bucket[5m])) > 2
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High response time"
          description: "P95 response time is above 2 seconds"

      # Database connection exhaustion
      - alert: DatabaseConnectionHigh
        expr: pg_stat_activity_count > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Database connections running high"

      # Redis memory usage
      - alert: RedisHighMemory
        expr: redis_memory_used_bytes / redis_memory_max_bytes > 0.8
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Redis memory usage above 80%"

      # Disk space
      - alert: DiskSpaceLow
        expr: node_filesystem_avail_bytes / node_filesystem_size_bytes < 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Disk space below 10%"

  - name: infrastructure
    interval: 1m
    rules:
      # Node down
      - alert: NodeDown
        expr: up{job="node"} == 0
        for: 2m
        labels:
          severity: critical

      # High CPU
      - alert: HighCPUUsage
        expr: rate(node_cpu_seconds_total{mode="user"}[5m]) > 0.8
        for: 10m
        labels:
          severity: warning

      # High memory
      - alert: HighMemoryUsage
        expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) > 0.85
        for: 5m
        labels:
          severity: warning
```

#### Alert Manager конфигурация

```yaml
# monitoring/alertmanager/config.yml
global:
  resolve_timeout: 5m
  slack_api_url: ${SLACK_WEBHOOK_URL}

route:
  receiver: default
  group_by: ['alertname', 'cluster', 'service']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h

  routes:
    # Critical alerts
    - match:
        severity: critical
      receiver: critical
      continue: true
      repeat_interval: 5m

    # Warning alerts
    - match:
        severity: warning
      receiver: warning
      repeat_interval: 1h

receivers:
  - name: 'default'
    slack_configs:
      - channel: '#alerts'
        title: '{{ .GroupLabels.alertname }}'
        text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'

  - name: 'critical'
    slack_configs:
      - channel: '#alerts-critical'
        title: 'CRITICAL: {{ .GroupLabels.alertname }}'
        text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'
    pagerduty_configs:
      - service_key: ${PAGERDUTY_SERVICE_KEY}

  - name: 'warning'
    slack_configs:
      - channel: '#alerts-warnings'
        title: 'WARNING: {{ .GroupLabels.alertname }}'
        text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'

inhibit_rules:
  - source_match:
      severity: critical
    target_match:
      severity: warning
    equal: ['alertname', 'service']
```

## Dashboards и KPIs

### MON-005: Custom Dashboards

#### Основной Dashboard

```json
{
  "dashboard": {
    "title": "A2D2 Platform Overview",
    "timezone": "UTC",
    "panels": [
      {
        "title": "Requests Per Second",
        "targets": [
          {
            "expr": "rate(rails_http_requests_total[5m])",
            "legendFormat": "{{method}} {{path}}"
          }
        ],
        "type": "graph"
      },
      {
        "title": "Error Rate",
        "targets": [
          {
            "expr": "rate(rails_http_requests_total{status=~\"5..\"}[5m])",
            "legendFormat": "5xx errors"
          }
        ],
        "type": "graph"
      },
      {
        "title": "Response Time (P95)",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(rails_http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "P95"
          }
        ],
        "type": "graph"
      },
      {
        "title": "Active Connections",
        "targets": [
          {
            "expr": "rails_active_connections",
            "legendFormat": "Database connections"
          }
        ],
        "type": "stat"
      },
      {
        "title": "System Resources",
        "targets": [
          {
            "expr": "node_cpu_seconds_total",
            "legendFormat": "CPU - {{instance}}"
          },
          {
            "expr": "node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes",
            "legendFormat": "Memory - {{instance}}"
          }
        ],
        "type": "graph"
      }
    ]
  }
}
```

#### KPI targets

| Метрика | Target | Frequency |
|---------|--------|-----------|
| Uptime | ≥99.5% | Real-time |
| Error Rate | <0.5% | 5-minute avg |
| Response Time (p95) | <2 seconds | 5-minute avg |
| Database Query Time | <500ms | per query |
| Cache Hit Rate | >80% | hourly |
| Background Job Completion | >99% | daily |
| SSL Certificate Validity | >30 days | daily |

---

**Статус**: ✓ Готово к развертыванию
**Дата обновления**: 28 октября 2025
