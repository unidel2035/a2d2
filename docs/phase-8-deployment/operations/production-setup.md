# DEPLOY-001: Настройка Production окружения

**Статус**: Завершено
**Версия**: 1.0
**Последнее обновление**: 2025-10-28

## Обзор

Этот документ описывает настройку production окружения для платформы A2D2, включая требования к инфраструктуре, конфигурацию и архитектуру развертывания.

## Production архитектура

### Высокоуровневая архитектура

```
                                    ┌─────────────────┐
                                    │   Load Balancer │
                                    │   (nginx/HAProxy)│
                                    └────────┬─────────┘
                                            │
                    ┌───────────────────────┴───────────────────────┐
                    │                                               │
            ┌───────▼────────┐                           ┌──────────▼────────┐
            │   App Server 1 │                           │   App Server 2    │
            │   (Rails+Solid)│                           │   (Rails+Solid)   │
            └───────┬────────┘                           └──────────┬────────┘
                    │                                               │
                    └───────────────────┬───────────────────────────┘
                                       │
                    ┌──────────────────┴──────────────────┐
                    │                                     │
            ┌───────▼────────┐                   ┌───────▼────────┐
            │   PostgreSQL   │◄──────replication─┤   PostgreSQL   │
            │   Primary      │                   │   Replica      │
            └────────────────┘                   └────────────────┘
                    │
                    │
            ┌───────▼────────┐
            │   Redis Cluster│
            │   (Cache+Queue)│
            └────────────────┘
```

## Требования к инфраструктуре

### Минимальные требования для Production

#### Серверы приложений (2+ экземпляра)
- **CPU**: 4 ядра
- **RAM**: 8 GB
- **Диск**: 100 GB SSD
- **ОС**: Ubuntu 22.04 LTS или новее
- **Сеть**: 1 Gbps

#### Сервер базы данных (Primary + Replica)
- **CPU**: 8 ядер
- **RAM**: 16 GB
- **Диск**: 500 GB SSD (рекомендуется NVMe)
- **ОС**: Ubuntu 22.04 LTS или новее
- **Сеть**: 1 Gbps

#### Сервер Redis Cache/Queue
- **CPU**: 2 ядра
- **RAM**: 4 GB
- **Диск**: 50 GB SSD
- **ОС**: Ubuntu 22.04 LTS или новее
- **Сеть**: 1 Gbps

### Рекомендуемая настройка для Production

Для высокой доступности и масштабируемости:

- **Серверы приложений**: 3-5 экземпляров за балансировщиком нагрузки
- **База данных**: PostgreSQL 14+ с потоковой репликацией (1 primary + 2 replicas)
- **Кеш**: Redis Cluster (3 master + 3 replica узла)
- **Балансировщик нагрузки**: nginx или HAProxy
- **CDN**: CloudFlare или аналог для статических ресурсов
- **Мониторинг**: Prometheus + Grafana + Loki
- **Резервное копирование**: Автоматические ежедневные бэкапы с хранением 30 дней

## Стек программного обеспечения

### Основные компоненты

```yaml
Ruby: 3.3.6
Rails: 8.1.0
PostgreSQL: 14.x or later
Redis: 7.x or later
nginx: 1.27.x
Node.js: 20.x LTS (for asset compilation)
```

### Ключевые зависимости

```ruby
# Production gems
puma              # Application server
solid-queue       # Background jobs
solid-cache       # Caching layer
thruster          # HTTP/2 proxy
bootsnap          # Boot optimization
```

## Переменные окружения

### Обязательные переменные окружения

Создайте файл `.env.production` или установите через инструмент развертывания:

```bash
# Application
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=false  # nginx serves static files
SECRET_KEY_BASE=<generate_with_rails_secret>

# Database
DATABASE_URL=postgresql://user:password@primary-db:5432/a2d2_production
DATABASE_REPLICA_URL=postgresql://user:password@replica-db:5432/a2d2_production

# Redis
REDIS_URL=redis://:password@redis-primary:6379/0
REDIS_CACHE_URL=redis://:password@redis-primary:6379/1
SOLID_QUEUE_REDIS_URL=redis://:password@redis-primary:6379/2

# Email (for notifications)
SMTP_ADDRESS=smtp.example.com
SMTP_PORT=587
SMTP_DOMAIN=example.com
SMTP_USERNAME=noreply@example.com
SMTP_PASSWORD=<smtp_password>
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true

# LLM API Keys (for AI agents)
OPENAI_API_KEY=<your_openai_key>
ANTHROPIC_API_KEY=<your_anthropic_key>
DEEPSEEK_API_KEY=<your_deepseek_key>
GOOGLE_API_KEY=<your_google_key>

# Monitoring
PROMETHEUS_EXPORTER_ENABLED=true
SENTRY_DSN=<your_sentry_dsn>  # Optional

# Performance
WEB_CONCURRENCY=2
RAILS_MAX_THREADS=5
MALLOC_ARENA_MAX=2  # Reduces memory fragmentation
```

### Генерация секретов

```bash
# Generate SECRET_KEY_BASE
rails secret

# Or use Rails credentials (recommended)
EDITOR=vim rails credentials:edit --environment production
```

## Настройка базы данных

### Конфигурация PostgreSQL

#### postgresql.conf (Primary Server)

```ini
# Connections
max_connections = 200
superuser_reserved_connections = 3

# Memory
shared_buffers = 4GB                    # 25% of RAM
effective_cache_size = 12GB             # 75% of RAM
maintenance_work_mem = 1GB
work_mem = 20MB

# Write-Ahead Logging
wal_level = replica
wal_buffers = 16MB
max_wal_senders = 5
max_replication_slots = 5
wal_keep_size = 1GB

# Checkpoint
checkpoint_completion_target = 0.9
checkpoint_timeout = 10min
max_wal_size = 4GB
min_wal_size = 1GB

# Query Planner
random_page_cost = 1.1                  # For SSD
effective_io_concurrency = 200          # For SSD

# Logging
log_destination = 'stderr'
logging_collector = on
log_directory = '/var/log/postgresql'
log_filename = 'postgresql-%Y-%m-%d.log'
log_rotation_age = 1d
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
log_checkpoints = on
log_lock_waits = on
log_min_duration_statement = 1000       # Log slow queries (>1s)

# Connection Pooling (via PgBouncer - optional)
# max_prepared_transactions = 100
```

#### pg_hba.conf

```ini
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# Local connections
local   all             all                                     peer
host    all             all             127.0.0.1/32            scram-sha-256
host    all             all             ::1/128                 scram-sha-256

# Replication connections
host    replication     replicator      <replica-ip>/32         scram-sha-256

# Application connections
host    a2d2_production a2d2_user       <app-server-ip>/32      scram-sha-256
```

### Конфигурация Redis

#### redis.conf (Production)

```ini
# Network
bind 0.0.0.0
protected-mode yes
port 6379
requirepass <strong_password>

# Persistence
save 900 1
save 300 10
save 60 10000
appendonly yes
appendfsync everysec

# Memory
maxmemory 3gb
maxmemory-policy allkeys-lru

# Performance
tcp-backlog 511
timeout 0
tcp-keepalive 300

# Logging
loglevel notice
logfile /var/log/redis/redis-server.log

# Security
rename-command FLUSHDB ""
rename-command FLUSHALL ""
rename-command KEYS ""
rename-command CONFIG "CONFIG-2f7e8a9b1c3d4e5f"
```

## Настройка сервера приложений

### Установка системных зависимостей

```bash
# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install dependencies
sudo apt-get install -y \
  build-essential \
  git \
  curl \
  libssl-dev \
  libreadline-dev \
  zlib1g-dev \
  libpq-dev \
  libxml2-dev \
  libxslt1-dev \
  libyaml-dev \
  libffi-dev \
  nodejs \
  npm \
  postgresql-client \
  redis-tools \
  nginx
```

### Установка Ruby

```bash
# Install rbenv
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
exec $SHELL

# Install ruby-build
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# Install Ruby 3.3.6
rbenv install 3.3.6
rbenv global 3.3.6

# Install bundler
gem install bundler
```

### Структура каталогов развертывания приложения

```
/var/www/a2d2/
├── current -> /var/www/a2d2/releases/20251028120000
├── releases/
│   ├── 20251028120000/
│   ├── 20251027150000/
│   └── 20251026180000/
├── shared/
│   ├── config/
│   │   ├── master.key
│   │   ├── database.yml
│   │   └── .env.production
│   ├── log/
│   ├── tmp/
│   ├── public/
│   │   └── uploads/
│   └── storage/
└── repo/  # Git repository cache
```

## Конфигурация балансировщика нагрузки

### Конфигурация nginx

#### /etc/nginx/nginx.conf

```nginx
user www-data;
worker_processes auto;
pid /run/nginx.pid;
worker_rlimit_nofile 65535;

events {
    worker_connections 4096;
    use epoll;
    multi_accept on;
}

http {
    ##
    # Basic Settings
    ##
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    ##
    # SSL Settings
    ##
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    ssl_session_cache shared:SSL:50m;
    ssl_session_timeout 1d;
    ssl_session_tickets off;

    ##
    # Logging Settings
    ##
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for" '
                    'rt=$request_time uct="$upstream_connect_time" '
                    'uht="$upstream_header_time" urt="$upstream_response_time"';

    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log warn;

    ##
    # Gzip Settings
    ##
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript
               application/json application/javascript application/xml+rss
               application/rss+xml font/truetype font/opentype
               application/vnd.ms-fontobject image/svg+xml;

    ##
    # Rate Limiting
    ##
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=general:10m rate=50r/s;

    ##
    # Upstream Configuration
    ##
    upstream a2d2_app {
        least_conn;
        server 10.0.1.10:3000 max_fails=3 fail_timeout=30s;
        server 10.0.1.11:3000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }

    ##
    # Virtual Host Configs
    ##
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
```

#### /etc/nginx/sites-available/a2d2

```nginx
# Redirect HTTP to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name a2d2.example.com;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$server_name$request_uri;
    }
}

# HTTPS Server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name a2d2.example.com;

    # SSL Certificates
    ssl_certificate /etc/letsencrypt/live/a2d2.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/a2d2.example.com/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/a2d2.example.com/chain.pem;

    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Root and index
    root /var/www/a2d2/current/public;
    index index.html;

    # Client max body size
    client_max_body_size 100M;

    # Static assets
    location ~ ^/(assets|packs|images|javascripts|stylesheets|fonts)/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    # Health check endpoint
    location /health {
        access_log off;
        proxy_pass http://a2d2_app;
        proxy_set_header Host $host;
    }

    # API endpoints with rate limiting
    location /api/ {
        limit_req zone=api burst=20 nodelay;

        proxy_pass http://a2d2_app;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;

        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Application proxy
    location / {
        limit_req zone=general burst=50 nodelay;

        try_files $uri @app;
    }

    location @app {
        proxy_pass http://a2d2_app;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;

        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Error pages
    error_page 500 502 503 504 /500.html;
    location = /500.html {
        root /var/www/a2d2/current/public;
    }
}
```

Включите сайт:

```bash
sudo ln -s /etc/nginx/sites-available/a2d2 /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## SSL/TLS сертификаты

### Использование Let's Encrypt

```bash
# Install certbot
sudo apt-get install certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d a2d2.example.com

# Auto-renewal (certbot installs a cron job automatically)
sudo certbot renew --dry-run
```

## Systemd сервис

### /etc/systemd/system/a2d2-web.service

```ini
[Unit]
Description=A2D2 Rails Application (Web)
After=network.target postgresql.service redis.service

[Service]
Type=simple
User=deploy
WorkingDirectory=/var/www/a2d2/current
Environment=RAILS_ENV=production
Environment=RAILS_LOG_TO_STDOUT=true
EnvironmentFile=/var/www/a2d2/shared/config/.env.production

ExecStart=/home/deploy/.rbenv/shims/bundle exec puma -C config/puma.rb
ExecReload=/bin/kill -USR2 $MAINPID

Restart=always
RestartSec=10

StandardOutput=append:/var/log/a2d2/web.log
StandardError=append:/var/log/a2d2/web-error.log

[Install]
WantedBy=multi-user.target
```

### /etc/systemd/system/a2d2-worker.service

```ini
[Unit]
Description=A2D2 Background Workers (Solid Queue)
After=network.target postgresql.service redis.service a2d2-web.service

[Service]
Type=simple
User=deploy
WorkingDirectory=/var/www/a2d2/current
Environment=RAILS_ENV=production
Environment=RAILS_LOG_TO_STDOUT=true
EnvironmentFile=/var/www/a2d2/shared/config/.env.production

ExecStart=/home/deploy/.rbenv/shims/bundle exec rake solid_queue:start

Restart=always
RestartSec=10

StandardOutput=append:/var/log/a2d2/worker.log
StandardError=append:/var/log/a2d2/worker-error.log

[Install]
WantedBy=multi-user.target
```

Включите и запустите сервисы:

```bash
sudo systemctl daemon-reload
sudo systemctl enable a2d2-web a2d2-worker
sudo systemctl start a2d2-web a2d2-worker
sudo systemctl status a2d2-web a2d2-worker
```

## Контрольный список безопасности

- [ ] Настроен файрвол (ufw/iptables)
- [ ] Аутентификация SSH только по ключу
- [ ] Установлен и настроен fail2ban
- [ ] База данных доступна только с серверов приложений
- [ ] Redis защищен паролем
- [ ] Установлены SSL/TLS сертификаты
- [ ] Настроены заголовки безопасности в nginx
- [ ] Переменные окружения защищены
- [ ] Настроена ротация логов приложения
- [ ] Включено шифрование резервных копий
- [ ] Настроен мониторинг и оповещения

## Следующие шаги

После завершения настройки production:

1. Перейдите к [Руководству по миграции базы данных](migration-guide.md)
2. Изучите [Развертывание без простоя](zero-downtime.md)
3. Настройте [Проверки работоспособности](health-checks.md)
4. Настройте [Процедуры отката](rollback-guide.md)

## Ссылки

- [Rails Production Deployment Guide](https://guides.rubyonrails.org/deployment.html)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [nginx Documentation](https://nginx.org/en/docs/)
- [Redis Documentation](https://redis.io/documentation)

---

**Версия документа**: 1.0
**Последнее обновление**: 2025-10-28
**Сопровождающий**: A2D2 DevOps Team
