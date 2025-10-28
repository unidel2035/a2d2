# Infrastructure Security

**Версия**: 1.0
**Статус**: Документировано
**Дата**: 28 октября 2025

## 📋 Содержание

1. [Network Security](#network-security)
2. [Data Protection](#data-protection)
3. [Access Control](#access-control)
4. [Security Scanning](#security-scanning)
5. [Compliance](#compliance)

## Network Security

### TLS/SSL Configuration

```nginx
# /etc/nginx/snippets/ssl-params.conf

# TLS 1.3 и TLS 1.2 only
ssl_protocols TLSv1.3 TLSv1.2;

# Modern ciphers
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;

ssl_prefer_server_ciphers on;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;

# HSTS (Strict-Transport-Security)
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

# Certificate pinning
add_header Public-Key-Pins 'pin-sha256="base64+primary=="; pin-sha256="base64+backup=="; max-age=5184000; includeSubDomains' always;
```

### Security Headers

```nginx
# /etc/nginx/snippets/security-headers.conf

# Prevent MIME type sniffing
add_header X-Content-Type-Options "nosniff" always;

# Clickjacking protection
add_header X-Frame-Options "SAMEORIGIN" always;

# XSS protection (for older browsers)
add_header X-XSS-Protection "1; mode=block" always;

# Referrer policy
add_header Referrer-Policy "strict-origin-when-cross-origin" always;

# Content Security Policy
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' cdn.example.com; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' api.example.com; frame-ancestors 'none';" always;

# Permissions Policy
add_header Permissions-Policy "geolocation=(), microphone=(), camera=(), magnetometer=(), gyroscope=(), accelerometer=()" always;
```

### Firewall Rules

```bash
#!/bin/bash
# scripts/setup-firewall.sh

# Enable UFW (Uncomplicated Firewall)
ufw --force enable

# Default policies
ufw default deny incoming
ufw default allow outgoing

# SSH (with rate limiting)
ufw limit 22/tcp comment "SSH"

# HTTP/HTTPS
ufw allow 80/tcp comment "HTTP"
ufw allow 443/tcp comment "HTTPS"

# Internal services (IP restricted)
# PostgreSQL
ufw allow from 10.0.0.0/8 to any port 5432 comment "PostgreSQL"

# Redis
ufw allow from 10.0.0.0/8 to any port 6379 comment "Redis"

# Show status
ufw status verbose
```

### DDoS Protection

```yaml
# CloudFlare DDoS settings
cloudflare:
  ddos_protection: "I'm Under Attack!"  # Aggressive
  rate_limiting:
    - path: /api/*
      rate: 100  # requests per 10 minutes
    - path: /login
      rate: 10   # requests per 10 minutes
  bot_management: enabled
  challenge_ttl: 30
```

## Data Protection

### Encryption at Rest

```ruby
# config/environments/production.rb

# Enable attribute encryption for sensitive data
require 'active_support/all'

# Use Active Support Encryption
Rails.application.config.active_support.key_generator_hash_digest_class = OpenSSL::Digest::SHA256

# Encrypt sensitive attributes
class User < ApplicationRecord
  encrypts :ssn
  encrypts :credit_card_number
  encrypts :password_digest
end
```

### Database Encryption

```bash
#!/bin/bash
# scripts/setup-db-encryption.sh

# PostgreSQL with pgcrypto
psql -U postgres -d a2d2_production <<EOF
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Create encrypted columns
ALTER TABLE users ADD COLUMN ssn_encrypted bytea;
ALTER TABLE users ADD COLUMN ssn_key bytea;

-- Encrypt existing data
UPDATE users
SET ssn_encrypted = pgp_sym_encrypt(ssn, 'encryption_key'),
    ssn_key = pgp_sym_encrypt('key_material', 'master_key');

-- Create view for transparent decryption
CREATE VIEW users_decrypted AS
SELECT
  id,
  email,
  pgp_sym_decrypt(ssn_encrypted, 'encryption_key') as ssn,
  created_at,
  updated_at
FROM users;
EOF
```

### File Encryption

```ruby
# app/models/document.rb
class Document < ApplicationRecord
  has_one_attached :file

  # Encrypt uploaded files
  before_save :encrypt_file

  private

  def encrypt_file
    if file.attached?
      encrypted_blob = encrypt_blob(file.download)
      # Store encrypted version
    end
  end

  def encrypt_blob(blob)
    cipher = OpenSSL::Cipher.new('AES-256-CBC')
    cipher.encrypt
    cipher.key = Rails.application.credentials.encryption_key
    encrypted = cipher.update(blob) + cipher.final
    { iv: cipher.random_iv, data: encrypted }
  end
end
```

## Access Control

### Network Access

```yaml
# Production security groups

InboundRules:
  - Protocol: TCP
    Port: 443
    Source: 0.0.0.0/0
    Description: "HTTPS"

  - Protocol: TCP
    Port: 80
    Source: 0.0.0.0/0
    Description: "HTTP (redirects to HTTPS)"

  - Protocol: TCP
    Port: 22
    Source: 203.0.113.0/32
    Description: "SSH - Admin only"

  - Protocol: TCP
    Port: 5432
    Source: 10.0.0.0/8
    Description: "PostgreSQL - Internal"

  - Protocol: TCP
    Port: 6379
    Source: 10.0.0.0/8
    Description: "Redis - Internal"

OutboundRules:
  - Protocol: -1
    Destination: 0.0.0.0/0
    Description: "Allow all outbound"
```

### SSH Key Management

```bash
#!/bin/bash
# scripts/setup-ssh-keys.sh

# Generate SSH keys
mkdir -p ~/.ssh
ssh-keygen -t ed25519 -f ~/.ssh/id_deploy -C "deployment@a2d2.example.com" -N ""

# Upload public key to servers
for server in production-web-{1..3}.internal; do
  ssh-copy-id -i ~/.ssh/id_deploy.pub deploy@$server
done

# Set permissions
chmod 600 ~/.ssh/id_deploy
chmod 644 ~/.ssh/id_deploy.pub

# Add to SSH agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_deploy

# Restrict key usage (in ~/.ssh/authorized_keys)
# command="bin/rails console",restrict ssh-rsa AAAA...
```

### Secret Management

```bash
#!/bin/bash
# scripts/setup-secrets.sh

# Using 1Password or similar
export RAILS_MASTER_KEY=$(op read "op://Private/Rails Master Key/credential")

# Or HashiCorp Vault
vault login -method=approle \
  -path=auth/approle \
  role_id=$VAULT_ROLE_ID \
  secret_id=$VAULT_SECRET_ID

vault kv get secret/a2d2/production/database_url
```

## Security Scanning

### Automated Security Scanning

```yaml
# .github/workflows/security.yml
name: Security Scanning

on:
  push:
    branches: [main]
  pull_request:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Ruby security
      - name: Run Brakeman
        run: bundle exec brakeman --no-pager

      # Dependency vulnerabilities
      - name: Run bundler-audit
        run: bundle exec bundler-audit

      # OWASP scanning
      - name: Run OWASP ZAP
        uses: zaproxy/action-full-scan@v0.7.0
        with:
          target: 'https://staging.example.com'
          rules_file_name: '.zap/rules.tsv'

      # Container scanning
      - name: Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'ghcr.io/unidel2035/a2d2:latest'
          format: 'sarif'
          output: 'trivy-results.sarif'

      # SAST scanning
      - name: SonarCloud Scan
        uses: SonarSource/sonarcloud-github-action@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

### Code Review Checklist

Before deployment, verify:

- [ ] No hardcoded credentials in code
- [ ] SQL queries use parameterized statements
- [ ] User input is properly validated/sanitized
- [ ] CSRF tokens present on all forms
- [ ] Authentication/authorization properly implemented
- [ ] SSL/TLS properly configured
- [ ] Sensitive data properly encrypted
- [ ] Error messages don't leak sensitive info
- [ ] Logs don't contain passwords/tokens
- [ ] Dependencies are up-to-date and secure

## Compliance

### GDPR Compliance

```ruby
# app/models/user.rb
class User < ApplicationRecord
  # Right to be forgotten
  def delete_all_data
    # Delete personal data
    update(
      email: SecureRandom.hex(10),
      first_name: nil,
      last_name: nil,
      phone: nil
    )

    # Delete associated data
    logs.destroy_all
    activity_history.destroy_all

    # Archive for compliance
    GdprArchive.create(
      user_id: id,
      data: archived_data,
      deleted_at: Time.current
    )
  end

  # Data export for portability
  def export_data
    {
      profile: serializable_hash(only: [:email, :first_name, :last_name]),
      logs: logs.map(&:as_json),
      activity: activity_history.map(&:as_json)
    }
  end
end
```

### Audit Logging

```ruby
# app/models/audit_log.rb
class AuditLog < ApplicationRecord
  validates :user_id, :action, :resource_type, :resource_id, presence: true

  enum action: { create: 0, update: 1, delete: 2, access: 3 }
  enum resource_type: { user: 0, document: 1, task: 2 }

  # Immutable records
  before_destroy do
    raise "Audit logs cannot be deleted"
  end

  # Tamper detection
  before_update do
    raise "Audit logs cannot be modified"
  end
end

# In ApplicationController
class ApplicationController < ActionController::Base
  around_action :audit_log

  private

  def audit_log
    audit_action = "access"

    yield

    if response.success?
      AuditLog.create(
        user_id: current_user&.id,
        action: audit_action,
        resource_type: controller_name,
        resource_id: params[:id],
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        details: { method: request.method, path: request.path }
      )
    end
  end
end
```

### Regular Security Audits

```bash
#!/bin/bash
# scripts/security-audit.sh

echo "🔐 Running comprehensive security audit..."

# Check for hardcoded secrets
echo "Scanning for hardcoded secrets..."
git grep -i -E "(password|secret|api_key|token).*=" | grep -v "\.example" || true

# Check file permissions
echo "Checking file permissions..."
find . -name "*.key" -ls
find . -name "*.pem" -ls
find . -name ".env*" -ls

# Check for insecure dependencies
echo "Checking for vulnerable dependencies..."
bundle audit

# Check SSL configuration
echo "Testing SSL configuration..."
testssl.sh --full a2d2.example.com > ssl-report.html

# Check OWASP Top 10
echo "Running OWASP security checks..."
zap-cli run --self-contained \
  --start-options '-config api.disablekey=true' \
  -a '.*' https://a2d2.example.com

echo "✅ Security audit complete!"
```

---

**Статус**: ✓ Готово к развертыванию
**Дата обновления**: 28 октября 2025
