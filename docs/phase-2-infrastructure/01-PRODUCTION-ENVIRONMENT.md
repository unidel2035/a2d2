# INFRA: Production окружение

**Версия**: 1.0
**Статус**: Документировано
**Дата**: 28 октября 2025

## 📋 Содержание

1. [Архитектура](#архитектура)
2. [PostgreSQL конфигурация](#postgresql-конфигурация)
3. [Redis кластер](#redis-кластер)
4. [Nginx настройка](#nginx-настройка)
5. [SSL/TLS конфигурация](#ssltls-конфигурация)
6. [CDN интеграция](#cdn-интеграция)
7. [Networking и безопасность](#networking-и-безопасность)

## Архитектура

```
┌─────────────────────────────────────────────────────────────┐
│                        Internet                             │
└──────────────────────────┬──────────────────────────────────┘
                           │
                    ┌──────▼──────┐
                    │   CDN       │
                    │ CloudFlare  │
                    └──────┬──────┘
                           │ (SSL/TLS)
                    ┌──────▼──────┐
                    │Load Balancer│
                    │ (SSL Term)  │
                    └──────┬──────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
   ┌────▼────┐        ┌────▼────┐       ┌───▼────┐
   │ Web-1   │        │ Web-2   │       │ Web-N  │
   │(Nginx)  │        │(Nginx)  │       │(Nginx) │
   │(Puma)   │        │(Puma)   │       │(Puma)  │
   └────┬────┘        └────┬────┘       └───┬────┘
        │                  │                │
        └──────────────────┼────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
   ┌────▼─────┐       ┌────▼──────┐     ┌───▼──────┐
   │PostgreSQL│       │  Redis    │     │S3 Storage│
   │ Primary  │       │  Master   │     │          │
   └────┬─────┘       └────┬──────┘     └──────────┘
        │                  │
   ┌────▼─────┐       ┌────▼──────┐
   │PostgreSQL│       │  Redis    │
   │ Replica  │       │  Replica  │
   └──────────┘       └───────────┘
```

## PostgreSQL конфигурация

### INFRA-001: PostgreSQL primary/replica с репликацией

#### Требования

```yaml
Version: PostgreSQL 14+
Primary:
  CPU: 2-4 cores
  RAM: 4-8 GB
  Storage: 100-500 GB SSD
Replica:
  CPU: 2-4 cores
  RAM: 4-8 GB
  Storage: 100-500 GB SSD
```

#### Переменные окружения

```bash
# Primary сервер
POSTGRES_DB=a2d2_production
POSTGRES_USER=a2d2_user
POSTGRES_PASSWORD=<strong-password>
POSTGRES_REPLICATION_USER=replicator
POSTGRES_REPLICATION_PASSWORD=<replication-password>

# Replica сервер
POSTGRES_PRIMARY_HOST=primary.db.internal
POSTGRES_PRIMARY_PORT=5432
POSTGRES_REPLICATION_MODE=standby
```

#### docker-compose.yml (для development/staging)

```yaml
services:
  postgres_primary:
    image: postgres:14-alpine
    environment:
      POSTGRES_DB: a2d2_production
      POSTGRES_USER: a2d2_user
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_INITDB_ARGS: |
        -c max_connections=200
        -c shared_buffers=256MB
        -c effective_cache_size=1GB
        -c maintenance_work_mem=64MB
        -c checkpoint_completion_target=0.9
        -c wal_buffers=16MB
        -c default_statistics_target=100
        -c random_page_cost=1.1
        -c effective_io_concurrency=200
        -c work_mem=1310kB
        -c max_worker_processes=2
        -c max_parallel_workers_per_gather=1
        -c max_parallel_workers=2
        -c max_parallel_maintenance_workers=1
    ports:
      - "5432:5432"
    volumes:
      - postgres_primary_data:/var/lib/postgresql/data
      - ./config/postgresql/postgresql.conf:/etc/postgresql/postgresql.conf
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U a2d2_user -d a2d2_production"]
      interval: 10s
      timeout: 5s
      retries: 5

  postgres_replica:
    image: postgres:14-alpine
    environment:
      POSTGRES_REPLICATION_MODE: standby
      POSTGRES_PRIMARY_HOST: postgres_primary
      POSTGRES_PRIMARY_PORT: 5432
      POSTGRES_REPLICATION_USER: replicator
      POSTGRES_REPLICATION_PASSWORD: ${POSTGRES_REPLICATION_PASSWORD}
    ports:
      - "5433:5432"
    volumes:
      - postgres_replica_data:/var/lib/postgresql/data
    depends_on:
      postgres_primary:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_primary_data:
  postgres_replica_data:
```

#### Конфигурация Production

1. **Replication setup**:
   ```bash
   # На primary сервере
   pg_basebackup -h primary.db.internal -D /var/lib/postgresql/data \
     -U replicator --password -v -P

   # На replica сервере - создать recovery.conf
   standby_mode = 'on'
   primary_conninfo = 'host=primary.db.internal port=5432 user=replicator password=xxx'
   restore_command = 'cp /var/lib/postgresql/archive/%f %p'
   ```

2. **Backup стратегия**:
   ```bash
   # Ежедневное полное backup
   pg_basebackup -h primary.db.internal -D /backup/postgresql \
     -U backup_user --password -v -P -x

   # WAL archiving
   archive_mode = on
   archive_command = 'test ! -f /mnt/archive/%f && cp %p /mnt/archive/%f'
   archive_timeout = 300
   ```

3. **Мониторинг**:
   ```sql
   -- Проверить статус replication
   SELECT slot_name, active FROM pg_replication_slots;
   SELECT * FROM pg_stat_replication;

   -- Проверить размер WAL
   SELECT pg_wal_lsn_diff(pg_current_wal_lsn(), '0/0');
   ```

## Redis кластер

### INFRA-002: Redis для кэширования и sessions

#### Архитектура

```
Master Redis        Replica 1 Redis     Replica 2 Redis
(6379)              (6379)              (6379)
   │                   │                    │
   └───────────────────┼────────────────────┘
                       │
              (Replication)
```

#### docker-compose.yml

```yaml
services:
  redis_master:
    image: redis:7-alpine
    command:
      - redis-server
      - --maxmemory=256mb
      - --maxmemory-policy=allkeys-lru
      - --save=60=1000
      - --appendonly=yes
      - --appendfsync=everysec
      - --requirepass=${REDIS_PASSWORD}
      - --masterauth=${REDIS_PASSWORD}
    ports:
      - "6379:6379"
    volumes:
      - redis_master_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis_replica_1:
    image: redis:7-alpine
    command:
      - redis-server
      - --slaveof=redis_master=6379
      - --requirepass=${REDIS_PASSWORD}
      - --masterauth=${REDIS_PASSWORD}
    ports:
      - "6380:6379"
    volumes:
      - redis_replica_1_data:/data
    depends_on:
      redis_master:
        condition: service_healthy

  redis_replica_2:
    image: redis:7-alpine
    command:
      - redis-server
      - --slaveof=redis_master=6379
      - --requirepass=${REDIS_PASSWORD}
      - --masterauth=${REDIS_PASSWORD}
    ports:
      - "6381:6379"
    volumes:
      - redis_replica_2_data:/data
    depends_on:
      redis_master:
        condition: service_healthy

volumes:
  redis_master_data:
  redis_replica_1_data:
  redis_replica_2_data:
```

#### Rails конфигурация

```ruby
# config/environments/production.rb

# Redis для cache
config.cache_store = :redis_cache_store,
  { url: ENV['REDIS_CACHE_URL'] || 'redis://redis_master:6379/1' }

# Redis для sessions (Solid Cache)
Rails.application.config.solid_cache_store = :redis,
  { url: ENV['REDIS_URL'] || 'redis://redis_master:6379/0' }

# Redis для Active Job (Solid Queue)
config.active_job.queue_adapter = :solid_queue

# Solid Queue Redis configuration
Rails.application.configure do
  config.solid_queue.connects_to = { database: { reading: :secondary, writing: :primary } }
end
```

## Nginx настройка

### INFRA-003: Nginx как reverse proxy и load balancer

#### nginx.conf

```nginx
upstream rails_app {
  server web1:3000;
  server web2:3000;
  server web3:3000;
  keepalive 32;
}

# Rate limiting
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=100r/s;
limit_req_zone $binary_remote_addr zone=app_limit:10m rate=50r/s;

server {
  listen 80 default_server;
  listen [::]:80 default_server;
  server_name _;

  # Redirect to HTTPS
  return 301 https://$host$request_uri;
}

server {
  listen 443 ssl http2 default_server;
  listen [::]:443 ssl http2 default_server;

  server_name a2d2.example.com;

  # SSL configuration
  ssl_certificate /etc/letsencrypt/live/a2d2.example.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/a2d2.example.com/privkey.pem;
  ssl_protocols TLSv1.3 TLSv1.2;
  ssl_ciphers HIGH:!aNULL:!MD5;
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:10m;
  ssl_session_timeout 10m;

  # Security headers
  add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
  add_header X-Content-Type-Options "nosniff" always;
  add_header X-Frame-Options "SAMEORIGIN" always;
  add_header X-XSS-Protection "1; mode=block" always;
  add_header Referrer-Policy "strict-origin-when-cross-origin" always;

  # Gzip compression
  gzip on;
  gzip_vary on;
  gzip_min_length 1000;
  gzip_types text/plain text/css text/xml text/javascript
             application/json application/javascript application/xml+rss
             application/rss+xml application/atom+xml image/svg+xml;

  # Client upload limit
  client_max_body_size 50M;

  # Static assets from S3/CDN
  location ~* ^/assets/ {
    expires 1y;
    add_header Cache-Control "public, immutable";
  }

  # API rate limiting
  location /api/ {
    limit_req zone=api_limit burst=10 nodelay;
    proxy_pass http://rails_app;
  }

  # Application
  location / {
    limit_req zone=app_limit burst=5 nodelay;

    proxy_pass http://rails_app;
    proxy_http_version 1.1;

    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Request-ID $request_id;

    proxy_connect_timeout 60s;
    proxy_send_timeout 60s;
    proxy_read_timeout 60s;

    proxy_buffering off;
    proxy_request_buffering off;
  }

  # Health check endpoint
  location /health {
    proxy_pass http://rails_app;
    access_log off;
  }

  # Deny access to sensitive files
  location ~ /\. {
    deny all;
    access_log off;
  }

  location ~ ~$ {
    deny all;
    access_log off;
  }
}
```

## SSL/TLS конфигурация

### INFRA-005: SSL/TLS с Let's Encrypt

#### Certbot автоматизация

```bash
#!/bin/bash
# scripts/setup-ssl.sh

DOMAIN="a2d2.example.com"
EMAIL="admin@example.com"

# Install certbot
apt-get update
apt-get install -y certbot python3-certbot-nginx

# Generate certificate
certbot certonly --nginx \
  --non-interactive \
  --agree-tos \
  --email $EMAIL \
  -d $DOMAIN

# Setup auto-renewal
systemctl enable certbot.timer
systemctl start certbot.timer

# Test renewal
certbot renew --dry-run
```

#### Nginx HTTPS конфигурация

```nginx
# /etc/nginx/snippets/ssl-params.conf

# TLS 1.3 и TLS 1.2
ssl_protocols TLSv1.3 TLSv1.2;
ssl_prefer_server_ciphers on;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;

# Session configuration
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;

# Perfect Forward Secrecy
ssl_dhparam /etc/nginx/dhparam.pem;

# HSTS
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
```

## CDN интеграция

### INFRA-004: CDN для статических ассетов

#### CloudFlare конфигурация

```yaml
# .cloudflare.yml
zone:
  name: example.com
  type: full

rules:
  - path: /assets/*
    ttl: 31536000  # 1 year
    cache_level: cache_everything
    edge_cache_ttl: 31536000
    browser_cache_ttl: 31536000

  - path: /public/*
    ttl: 86400  # 1 day
    cache_level: cache_everything

  - path: /api/*
    ttl: 0
    cache_level: bypass

  - path: /*
    ttl: 3600  # 1 hour
    cache_level: standard

security:
  ssl_mode: full  # or full_strict
  min_tls_version: 1.2
  tls_1_3: on
  security_level: medium

waf:
  enabled: true
  owasp_rules: true
  rate_limiting: true
```

#### Rails конфигурация для CDN

```ruby
# config/environments/production.rb

# Asset host для CDN
config.asset_host = 'https://cdn.example.com'

# Configure Active Storage для S3
config.active_storage.service = :amazon
config.active_storage.resolve_model_to_route = :rails_representation_url
```

## Networking и безопасность

### Network Architecture

```
Internet
   │
   ├─ CloudFlare (CDN, DDoS Protection)
   │
   ├─ AWS EC2 / Digital Ocean / Linode
   │
   ├─ Security Group / Firewall Rules
   │     ├─ Port 80 (HTTP → HTTPS redirect)
   │     ├─ Port 443 (HTTPS)
   │     └─ Port 22 (SSH, restricted IPs only)
   │
   ├─ Load Balancer
   │
   ├─ Web Servers (Private Network)
   │     ├─ Web1 (3000)
   │     ├─ Web2 (3000)
   │     └─ Web3 (3000)
   │
   └─ Data Tier (Private Database Network)
         ├─ PostgreSQL Primary (5432)
         ├─ PostgreSQL Replica (5432)
         ├─ Redis Master (6379)
         └─ Redis Replicas (6379-6381)
```

### Firewall Rules

```yaml
# Production security group rules

Inbound:
  - Protocol: TCP
    Port: 80
    Source: 0.0.0.0/0  # CloudFlare IPs

  - Protocol: TCP
    Port: 443
    Source: 0.0.0.0/0

  - Protocol: TCP
    Port: 22
    Source: 203.0.113.0/24  # Admin IPs only

  - Protocol: TCP
    Port: 5432  # PostgreSQL
    Source: 10.0.0.0/8  # Internal only

  - Protocol: TCP
    Port: 6379  # Redis
    Source: 10.0.0.0/8  # Internal only

Outbound:
  - All protocols/ports allowed
```

---

**Документировано**: 28 октября 2025
**Проверено**: ✓
**Статус**: Готово к развертыванию
