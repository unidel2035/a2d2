# Архитектурные диаграммы системы A2D2

**Версия**: 1.0
**Дата**: 28 октября 2025
**Формат**: PlantUML

---

## 1. System Context Diagram (Контекстная диаграмма системы)

```plantuml
@startuml System Context Diagram
!theme plain
left to right direction

actor "End Users" as users
actor "Administrators" as admins
actor "External Systems" as external

rectangle "A2D2 Platform" as a2d2 #LightBlue

users -->|Web UI| a2d2
admins -->|Admin UI| a2d2
a2d2 -->|REST API| external
external -->|Data Integration| a2d2

note on link
  - Dashboard
  - Agent Management
  - Task Monitoring
end note

@enduml
```

---

## 2. Functional Decomposition (Диаграмма декомпозиции функций)

```plantuml
@startuml Functional Breakdown
!theme plain
left to right direction

rectangle "A2D2 System" {
  rectangle "Meta-Layer (Orchestration)" {
    rectangle "Orchestrator"
    rectangle "Task Queue Manager"
    rectangle "Agent Registry"
    rectangle "Verification Layer"
    rectangle "Memory Management"
  }

  rectangle "Agent System" {
    rectangle "Analyzer Agent"
    rectangle "Transformer Agent"
    rectangle "Validator Agent"
    rectangle "Reporter Agent"
    rectangle "Integration Agent"
  }

  rectangle "Presentation Layer" {
    rectangle "Web UI"
    rectangle "REST API"
    rectangle "WebSocket"
  }

  rectangle "Data Layer" {
    rectangle "PostgreSQL Database"
    rectangle "Redis Cache"
    rectangle "File Storage"
  }
}

@enduml
```

---

## 3. Component Architecture (Диаграмма компонентов)

```plantuml
@startuml Component Diagram
!theme plain

package "Frontend" {
  component [Web Browser] as web_ui
  component [REST Client] as rest_client
}

package "API Gateway" {
  component [Rack Middleware] as middleware
  component [Authentication] as auth
  component [Rate Limiter] as limiter
}

package "Application Layer" {
  component [Controllers] as controllers
  component [Services] as services
  component [Models] as models
}

package "Meta-Layer" {
  component [Orchestrator] as orchestrator
  component [Task Queue] as task_queue
  component [Agent Registry] as agent_registry
  component [Verification] as verification
}

package "Agent Subsystem" {
  component [Analyzer] as analyzer
  component [Transformer] as transformer
  component [Validator] as validator
  component [Reporter] as reporter
  component [Integration] as integration
}

package "Data Layer" {
  component [PostgreSQL] as postgres
  component [Redis] as redis
  component [S3 Storage] as s3
}

web_ui --> rest_client
rest_client --> middleware
middleware --> auth
auth --> limiter
limiter --> controllers
controllers --> services
services --> models

models --> postgres
models --> redis
models --> s3

services --> orchestrator
orchestrator --> task_queue
orchestrator --> agent_registry
orchestrator --> verification

task_queue --> analyzer
task_queue --> transformer
task_queue --> validator
task_queue --> reporter
task_queue --> integration

@enduml
```

---

## 4. Deployment Diagram (Диаграмма развертывания)

```plantuml
@startuml Deployment Diagram
!theme plain

node "Internet" as internet
node "CDN (CloudFlare)" as cdn
node "Load Balancer" as lb
node "Web Server 1" as web1 {
  component [Puma] as puma1
  component [Rails App] as rails1
}
node "Web Server 2" as web2 {
  component [Puma] as puma2
  component [Rails App] as rails2
}

node "Database Cluster" as db_cluster {
  node "PostgreSQL Master" as pg_master
  node "PostgreSQL Replica" as pg_replica
  node "Backup Server" as backup
}

node "Cache Layer" as cache {
  node "Redis Master" as redis_m
  node "Redis Replica" as redis_r
}

node "File Storage" as storage {
  component [AWS S3] as s3
}

node "Monitoring Stack" as monitoring {
  component [Prometheus] as prom
  component [Grafana] as grafana
}

internet --> cdn
cdn --> lb
lb --> web1
lb --> web2

web1 --> pg_master
web2 --> pg_master
pg_master --> pg_replica
pg_master --> backup

web1 --> redis_m
web2 --> redis_m
redis_m --> redis_r

web1 --> s3
web2 --> s3

web1 --> prom
web2 --> prom
prom --> grafana

@enduml
```

---

## 5. Agent Lifecycle (Диаграмма состояний агента)

```plantuml
@startuml Agent Lifecycle
!theme plain

state "Registered" as registered
state "Idle" as idle
state "Working" as working
state "Error" as error
state "Maintenance" as maintenance
state "Offline" as offline
state "Retired" as retired

registered --> idle: Initialize
idle --> working: Task assigned
working --> idle: Task completed
working --> error: Task failed
error --> idle: Auto-recover
error --> offline: Too many errors
idle --> maintenance: Schedule maintenance
maintenance --> idle: Maintenance done
idle --> offline: Heartbeat timeout
offline --> idle: Reconnect
offline --> retired: Manual removal
idle --> retired: Manual decommission

@enduml
```

---

## 6. Task Processing Flow (Диаграмма потока обработки задачи)

```plantuml
@startuml Task Processing Flow
!theme plain

start

:User creates task;

:Task enters Queue;

:Orchestrator selects Agent
  based on:
  - Capabilities match
  - Current load
  - Priority;

:Task assigned to Agent;

:Agent processes task;

decision "Task successful?"
  case yes
    :Store result;
    :Verification passes;
  case no
    :Log error;
    decision "Retry?"
      case yes
        :Re-queue task;
      case no
        :Mark as failed;
    endcase
endcase

:Notify user;

end

@enduml
```

---

## 7. Agent Communication Protocol (Диаграмма последовательности взаимодействия)

```plantuml
@startuml Sequence Diagram - Agent Communication

participant User as U
participant Orchestrator as O
participant Agent as A
participant Database as D
participant Cache as C

U -> O: Create task\n(POST /api/v1/tasks)
O -> O: Select best agent
O -> A: Assign task\n(message queue)
A -> A: Process task
A -> D: Fetch required data
D -> A: Return data
A -> C: Cache intermediate results
A -> A: Perform analysis
A -> D: Store result
A -> O: Task completed\n(webhook)
O -> C: Update task status
O -> U: Notify completion\n(WebSocket)

@enduml
```

---

## 8. Database Schema (ER диаграмма)

```plantuml
@startuml Entity Relationship Diagram
!theme plain

entity "agents" as agents {
  *id : UUID PK
  --
  name : string
  type : enum
  status : enum
  capabilities : jsonb
  configuration : jsonb
  created_at : timestamp
  updated_at : timestamp
}

entity "tasks" as tasks {
  *id : UUID PK
  --
  agent_id : UUID FK
  title : string
  status : enum
  parameters : jsonb
  result : jsonb
  priority : integer
  deadline : timestamp
  created_at : timestamp
  updated_at : timestamp
}

entity "task_logs" as logs {
  *id : UUID PK
  --
  task_id : UUID FK
  level : enum
  message : text
  context : jsonb
  created_at : timestamp
}

entity "agent_metrics" as metrics {
  *id : UUID PK
  --
  agent_id : UUID FK
  cpu_usage : float
  memory_usage : float
  tasks_completed : integer
  error_rate : float
  recorded_at : timestamp
}

entity "users" as users {
  *id : UUID PK
  --
  email : string
  encrypted_password : string
  role : enum
  created_at : timestamp
}

agents ||--o{ tasks : "processes"
tasks ||--o{ logs : "generates"
agents ||--o{ metrics : "produces"
users ||--o{ tasks : "creates"

@enduml
```

---

## 9. System Information Flow (Информационные потоки)

```plantuml
@startuml Information Flow
!theme plain

rectangle "External Sources" {
  rectangle "LLM Providers" as llm
  rectangle "Enterprise Systems" as enterprise
  rectangle "Data Files" as files
}

rectangle "A2D2 System" {
  rectangle "Integration Agent" as int_agent
  rectangle "Transformer Agent" as trans_agent
  rectangle "Analyzer Agent" as ana_agent
  rectangle "Data Store" as store
}

rectangle "Output" {
  rectangle "Reports" as reports
  rectangle "Alerts" as alerts
  rectangle "API" as api
}

llm --> int_agent
enterprise --> int_agent
files --> int_agent

int_agent --> trans_agent
trans_agent --> ana_agent
ana_agent --> store

store --> reports
store --> alerts
store --> api

@enduml
```

---

## 10. Detailed Architecture - Meta-Layer

```plantuml
@startuml Meta-Layer Architecture
!theme plain

package "Task Management" {
  component [Task Queue] as queue
  component [Task Scheduler] as scheduler
  component [Retry Manager] as retry
}

package "Agent Management" {
  component [Agent Registry] as registry
  component [Agent Monitor] as monitor
  component [Agent Loader] as loader
}

package "Verification & Validation" {
  component [Result Validator] as validator
  component [Quality Checker] as checker
  component [Error Handler] as error_handler
}

package "Memory & Context" {
  component [Context Cache] as context_cache
  component [Memory Manager] as memory_mgr
  component [Knowledge Base] as kb
}

package "Orchestration" {
  component [Task Router] as router
  component [Load Balancer] as lb
  component [Coordinator] as coordinator
}

queue --> router
scheduler --> queue
monitor --> loader
registry --> monitor
router --> registry

validator --> checker
checker --> error_handler

router --> context_cache
memory_mgr --> context_cache
context_cache --> kb

coordinator --> router
coordinator --> monitor

@enduml
```

---

## 11. Security Layers

```plantuml
@startuml Security Architecture
!theme plain

package "Network Layer" {
  component [TLS 1.3] as tls
  component [DDoS Protection] as ddos
  component [WAF] as waf
}

package "Authentication Layer" {
  component [JWT Tokens] as jwt
  component [MFA] as mfa
  component [Session Manager] as session
}

package "Authorization Layer" {
  component [RBAC Engine] as rbac
  component [Policy Evaluator] as policy
  component [Audit Logger] as audit
}

package "Data Protection" {
  component [Encryption] as enc
  component [Key Manager] as keymgr
  component [Data Masking] as mask
}

package "Infrastructure" {
  component [Network Isolation] as network
  component [Container Security] as container
  component [Secret Management] as secrets
}

tls --> ddos
ddos --> waf
waf --> jwt
jwt --> mfa
mfa --> session
session --> rbac
rbac --> policy
policy --> audit

enc --> keymgr
keymgr --> mask

network --> container
container --> secrets

@enduml
```

---

## 12. Scaling Architecture

```plantuml
@startuml Scaling Architecture
!theme plain

cloud "Internet" as inet

node "Load Balancer" as lb {
  component [DNS] as dns
  component [SSL Termination] as ssl
  component [Request Routing] as routing
}

node "Web Tier (Horizontal)" as web_tier {
  node "Web Server 1" as web1
  node "Web Server 2" as web2
  node "Web Server N" as webN
}

node "Cache Tier" as cache_tier {
  node "Redis Master" as redis_m
  node "Redis Replica 1" as redis_r1
  node "Redis Replica 2" as redis_r2
}

node "Data Tier" as data_tier {
  node "PostgreSQL Master" as pg_m
  node "PostgreSQL Replica 1" as pg_r1
  node "PostgreSQL Replica 2" as pg_r2
  node "Backup Storage" as backup
}

inet --> lb
lb --> routing
routing --> web1
routing --> web2
routing --> webN

web1 --> redis_m
web2 --> redis_m
webN --> redis_m

redis_m --> redis_r1
redis_m --> redis_r2

web1 --> pg_m
web2 --> pg_m
webN --> pg_m

pg_m --> pg_r1
pg_m --> pg_r2
pg_m --> backup

@enduml
```

---

**Диаграммы созданы в формате PlantUML**

Для просмотра и рендеринга диаграмм используйте:
- [PlantUML Online Editor](http://www.plantuml.com/plantuml/uml/)
- VS Code Extension: PlantUML
- GitHub Markdown (автоматический рендеринг)

**Статус**: 🟢 Утверждено
