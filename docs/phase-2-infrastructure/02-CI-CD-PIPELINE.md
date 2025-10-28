# CI/CD Pipeline

**Версия**: 1.0
**Статус**: Документировано и реализовано
**Дата**: 28 октября 2025

## 📋 Содержание

1. [Pipeline Overview](#pipeline-overview)
2. [GitHub Actions конфигурация](#github-actions-конфигурация)
3. [Stages и Jobs](#stages-и-jobs)
4. [Code Quality](#code-quality)
5. [Security Scanning](#security-scanning)
6. [Deployment Pipeline](#deployment-pipeline)

## Pipeline Overview

### CICD-001: Автоматическое тестирование

```
Push to GitHub
      │
      ├─────────────────────────────────────┐
      │                                     │
      ▼                                     ▼
  CI Pipeline                        Pull Request
      │                             Checks
      ├─ Lint (RuboCop)                    │
      ├─ Security (Brakeman)               │
      ├─ Dependencies (bundler-audit)      │
      ├─ Unit Tests                        │
      ├─ Integration Tests                 │
      └─ System Tests                      │
            │                              │
            └──────────┬───────────────────┘
                       │
                  All checks pass
                       │
                       ▼
              Ready to merge
```

## GitHub Actions конфигурация

### Enhanced CI/CD Workflow

```yaml
# .github/workflows/ci.yml

name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

permissions:
  contents: read
  checks: write
  pull-requests: write

env:
  RUBY_VERSION: "3.3.6"
  NODE_VERSION: "20"

jobs:
  # Job 1: Code Quality
  lint:
    name: Lint Code
    runs-on: ubuntu-latest
    timeout-minutes: 10

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ env.RUBY_VERSION }}
          bundler-cache: true
          cache-version: 1

      - name: Lint code style
        run: |
          bundle exec rubocop --format github

  # Job 2: Security Analysis - Brakeman
  scan_ruby:
    name: Security Scan (Ruby)
    runs-on: ubuntu-latest
    timeout-minutes: 15

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ env.RUBY_VERSION }}
          bundler-cache: true
          cache-version: 1

      - name: Scan for Rails vulnerabilities
        run: |
          bundle exec brakeman -f json --no-summary -q > brakeman.json || true
          bundle exec brakeman --no-pager

  # Job 3: Dependencies Security
  dependencies:
    name: Check Dependencies
    runs-on: ubuntu-latest
    timeout-minutes: 10

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ env.RUBY_VERSION }}
          bundler-cache: true
          cache-version: 1

      - name: Scan for known vulnerabilities
        run: bundle exec bundler-audit

      - name: Check outdated gems
        run: bundle outdated --strict || true

  # Job 4: Unit Tests
  test:
    name: Unit Tests
    runs-on: ubuntu-latest
    timeout-minutes: 30

    services:
      postgres:
        image: postgres:14-alpine
        env:
          POSTGRES_DB: a2d2_test
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

      redis:
        image: redis:7-alpine
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379

    env:
      RAILS_ENV: test
      DATABASE_URL: postgres://postgres:postgres@localhost:5432/a2d2_test
      REDIS_URL: redis://localhost:6379

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ env.RUBY_VERSION }}
          bundler-cache: true
          cache-version: 1

      - name: Prepare database
        run: |
          bin/rails db:create
          bin/rails db:schema:load

      - name: Run unit tests
        run: bin/rails test
        continue-on-error: false

  # Job 5: Integration Tests
  integration_test:
    name: Integration Tests
    runs-on: ubuntu-latest
    timeout-minutes: 30

    services:
      postgres:
        image: postgres:14-alpine
        env:
          POSTGRES_DB: a2d2_test
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

      redis:
        image: redis:7-alpine
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379

    env:
      RAILS_ENV: test
      DATABASE_URL: postgres://postgres:postgres@localhost:5432/a2d2_test
      REDIS_URL: redis://localhost:6379

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ env.RUBY_VERSION }}
          bundler-cache: true
          cache-version: 1

      - name: Set up Node
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}

      - name: Prepare database
        run: |
          bin/rails db:create
          bin/rails db:schema:load

      - name: Run integration tests
        run: bin/rails test:integration
        continue-on-error: false

  # Job 6: System Tests
  system_test:
    name: System Tests
    runs-on: ubuntu-latest
    timeout-minutes: 45

    services:
      postgres:
        image: postgres:14-alpine
        env:
          POSTGRES_DB: a2d2_test
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

      redis:
        image: redis:7-alpine
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379

    env:
      RAILS_ENV: test
      DATABASE_URL: postgres://postgres:postgres@localhost:5432/a2d2_test
      REDIS_URL: redis://localhost:6379

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ env.RUBY_VERSION }}
          bundler-cache: true
          cache-version: 1

      - name: Set up Node
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}

      - name: Prepare database
        run: |
          bin/rails db:create
          bin/rails db:schema:load

      - name: Run system tests
        run: bin/rails test:system
        continue-on-error: false

      - name: Upload screenshots on failure
        uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: system-test-screenshots
          path: tmp/screenshots
          retention-days: 7

  # Job 7: Code Coverage
  coverage:
    name: Code Coverage
    runs-on: ubuntu-latest
    timeout-minutes: 30

    services:
      postgres:
        image: postgres:14-alpine
        env:
          POSTGRES_DB: a2d2_test
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

    env:
      RAILS_ENV: test
      DATABASE_URL: postgres://postgres:postgres@localhost:5432/a2d2_test

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ env.RUBY_VERSION }}
          bundler-cache: true
          cache-version: 1

      - name: Prepare database
        run: |
          bin/rails db:create
          bin/rails db:schema:load

      - name: Run tests with coverage
        run: |
          bundle exec simplecov
        env:
          COVERAGE: 'true'

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/.resultset.json
          flags: unittests
          name: codecov-umbrella
          fail_ci_if_error: false

  # Job 8: Build Docker Image (on merge to main)
  build:
    name: Build Docker Image
    runs-on: ubuntu-latest
    timeout-minutes: 30
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    needs: [lint, scan_ruby, dependencies, test, integration_test, system_test]

    permissions:
      contents: read
      packages: write

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Build Docker image
        uses: docker/build-push-action@v4
        with:
          context: .
          tags: |
            ghcr.io/${{ github.repository }}:latest
            ghcr.io/${{ github.repository }}:${{ github.sha }}
          push: false
          cache-from: type=registry,ref=ghcr.io/${{ github.repository }}:buildcache
          cache-to: type=registry,ref=ghcr.io/${{ github.repository }}:buildcache,mode=max

  # Notification
  notify:
    name: Notify Results
    runs-on: ubuntu-latest
    needs: [lint, scan_ruby, dependencies, test, integration_test, system_test]
    if: always()

    steps:
      - name: Send Slack notification
        uses: 8398a7/action-slack@v3
        if: failure()
        with:
          status: ${{ job.status }}
          text: 'CI Pipeline Failed'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
          fields: |
            repo,message,commit,author,action,eventName
```

## Stages и Jobs

### 1. Lint Stage (RuboCop)

**Purpose**: Ensure code style consistency

**CICD-002: Code quality checks**

```yaml
# .rubocop.yml configuration
inherit_from: .rubocop_todo.yml

AllCops:
  TargetRubyVersion: 3.3.6
  TargetRailsVersion: 8.1
  Exclude:
    - 'vendor/**/*'
    - 'db/schema.rb'
    - 'bin/**/*'

# Omakase Ruby style guide
Style/StringLiterals:
  EnforcedStyle: double_quotes

Layout/LineLength:
  Max: 120

# Custom rules
Rails:
  Enabled: true
```

### 2. Security Stage (Brakeman)

**Purpose**: Detect security vulnerabilities

**CICD-003: Security vulnerability scanning**

```bash
# config/brakeman.yml
exclude_paths:
  - app/vendor
  - vendor
  - node_modules

exclude_checks:
  - ContentTag

rails_version: "8.1"
```

### 3. Dependencies Stage (bundler-audit)

```bash
# config/bundler-audit.yml
ignore:
  # CVE-XXXX-XXXXX: Description
  # (uncomment to ignore specific CVEs)
```

### 4. Test Stage

**Metrics**:
- Unit test coverage: >90%
- Integration test coverage: >85%
- System test coverage: >75%

## Security Scanning

### CICD-003: Security vulnerability scanning

**Tools**:
1. **Brakeman** - Rails security analysis
2. **bundler-audit** - Gem vulnerability checking
3. **Importmap audit** - JavaScript dependencies
4. **OWASP ZAP** - Dynamic application security testing

```bash
# Run all security checks locally
bin/brakeman --no-pager
bin/bundler-audit
bin/importmap audit
```

## Deployment Pipeline

### CICD-004 & CICD-005: Automated deployment

```yaml
# .github/workflows/deploy.yml

name: Deploy

on:
  push:
    branches:
      - main
    paths-ignore:
      - 'docs/**'
      - '**.md'
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        default: 'staging'
        type: choice
        options:
          - staging
          - production

jobs:
  deploy_staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' || github.event.inputs.environment == 'staging'
    environment:
      name: staging
      url: https://staging.example.com

    steps:
      - uses: actions/checkout@v4

      - name: Deploy with Kamal
        env:
          KAMAL_REGISTRY_USERNAME: ${{ secrets.REGISTRY_USERNAME }}
          KAMAL_REGISTRY_PASSWORD: ${{ secrets.REGISTRY_PASSWORD }}
          RAILS_MASTER_KEY: ${{ secrets.RAILS_MASTER_KEY_STAGING }}
        run: |
          gem install kamal
          kamal deploy -s staging

      - name: Run smoke tests
        run: |
          curl -f https://staging.example.com/health || exit 1
          echo "Staging deployment successful"

  deploy_production:
    name: Deploy to Production
    runs-on: ubuntu-latest
    if: github.event.inputs.environment == 'production'
    environment:
      name: production
      url: https://example.com
    needs: deploy_staging

    steps:
      - uses: actions/checkout@v4

      - name: Blue-Green Deployment
        env:
          KAMAL_REGISTRY_USERNAME: ${{ secrets.REGISTRY_USERNAME }}
          KAMAL_REGISTRY_PASSWORD: ${{ secrets.REGISTRY_PASSWORD }}
          RAILS_MASTER_KEY: ${{ secrets.RAILS_MASTER_KEY_PRODUCTION }}
        run: |
          gem install kamal
          kamal deploy -s production

      - name: Run production tests
        run: |
          curl -f https://example.com/health || exit 1
          echo "Production deployment successful"

      - name: Notify deployment
        if: success()
        uses: 8398a7/action-slack@v3
        with:
          status: success
          text: 'Production deployment completed successfully'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

---

**Статус**: ✓ Готово к использованию
**Дата обновления**: 28 октября 2025
