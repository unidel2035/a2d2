/**
 * A2D2 TypeScript Interfaces
 * Автоматически сгенерированные интерфейсы из Rails моделей
 *
 * Этот файл содержит TypeScript интерфейсы для всех основных моделей системы A2D2.
 * Интерфейсы синхронизированы со схемой базы данных Rails (db/schema.rb).
 *
 * @package A2D2
 * @version 1.0.0
 * @generated 2025-10-29
 *
 * ВНИМАНИЕ: Этот файл должен обновляться при изменении схемы БД.
 * Для обновления интерфейсов используйте: ruby script/generate_typescript_interfaces.rb
 */

// ============================================================================
// Workflow System Interfaces (n8n-compatible)
// ============================================================================

/**
 * IWorkflow - интерфейс для модели workflows
 * Представляет автоматизированный рабочий процесс в стиле n8n
 */
export interface IWorkflow {
  id: number;
  name: string;
  status: 'active' | 'inactive' | 'error'; // default: inactive
  settings?: string; // JSON serialized
  static_data?: string; // JSON serialized
  tags?: string; // JSON serialized
  project_id?: number;
  user_id?: number;
  created_at: string;
  updated_at: string;
}

/**
 * IWorkflowNode - интерфейс для модели workflow_nodes
 * Представляет узел (node) в рабочем процессе
 */
export interface IWorkflowNode {
  id: number;
  workflow_id: number;
  name: string;
  node_type: string; // Тип узла: trigger, action, condition и т.д.
  type_version: number; // default: 1
  position?: string; // JSON: [x, y] координаты на canvas
  parameters?: string; // JSON: параметры узла
  credentials?: string; // JSON: учетные данные
  created_at: string;
  updated_at: string;
}

/**
 * IWorkflowConnection - интерфейс для модели workflow_connections
 * Представляет соединение между узлами в рабочем процессе
 */
export interface IWorkflowConnection {
  id: number;
  workflow_id: number;
  source_node_id: number;
  target_node_id: number;
  connection_type: string; // default: main (может быть: main, error, etc.)
  source_output_index: number; // default: 0
  target_input_index: number; // default: 0
  created_at: string;
  updated_at: string;
}

/**
 * IWorkflowExecution - интерфейс для модели workflow_executions
 * Представляет исполнение рабочего процесса
 */
export interface IWorkflowExecution {
  id: number;
  workflow_id: number;
  status: 'new' | 'running' | 'success' | 'error' | 'waiting' | 'canceled'; // default: new
  mode?: string; // manual, trigger, webhook, etc.
  started_at?: string;
  finished_at?: string;
  stopped_at?: string;
  data?: string; // JSON: данные исполнения
  error_message?: string;
  created_at: string;
  updated_at: string;
}

// ============================================================================
// Agent System Interfaces (Multi-Agent Orchestration)
// ============================================================================

/**
 * IAgent - интерфейс для модели agents
 * Представляет интеллектуального агента в системе
 */
export interface IAgent {
  id: number;
  type: string; // STI: Agents::AnalyzerAgent, Agents::ValidatorAgent, etc.
  name: string;
  description?: string;
  status: 'idle' | 'busy' | 'offline' | 'error'; // default: idle
  capabilities: Record<string, any>; // default: {}
  configuration: Record<string, any>; // default: {}
  version?: string;

  // Метрики производительности
  max_concurrent_tasks: number; // default: 5
  current_task_count: number; // default: 0
  total_tasks_completed: number; // default: 0
  total_tasks_failed: number; // default: 0
  success_rate: number; // default: 100.0
  average_completion_time: number; // default: 0
  load_score: number; // default: 0

  // Мониторинг
  last_heartbeat_at?: string;
  heartbeat_interval: number; // default: 300 (секунд)
  performance_metrics?: string; // JSON
  specialization_tags?: string; // JSON array

  created_at: string;
  updated_at: string;
}

/**
 * IAgentTask - интерфейс для модели agent_tasks
 * Представляет задачу, назначенную агенту
 */
export interface IAgentTask {
  id: number;
  agent_id?: number;
  task_type: string; // analysis, validation, transformation, reporting, integration
  status: 'pending' | 'assigned' | 'running' | 'completed' | 'failed' | 'cancelled'; // default: pending
  priority: number; // default: 5 (1-10, где 10 - наивысший)

  // Данные задачи
  input_data?: Record<string, any>;
  output_data?: Record<string, any>;
  metadata: Record<string, any>; // default: {}

  // Планирование и выполнение
  scheduled_at?: string;
  deadline_at?: string;
  started_at?: string;
  completed_at?: string;

  // Повторные попытки и обработка ошибок
  retry_count: number; // default: 0
  max_retries: number; // default: 3
  error_message?: string;

  // Оркестрация
  assigned_strategy?: string; // round-robin, least-loaded, capability-match
  dependencies?: string; // JSON: массив ID зависимых задач
  execution_context?: string; // JSON: контекст выполнения

  // Верификация качества
  verification_status?: 'pending' | 'verified' | 'failed' | 'rejected';
  quality_score?: number; // 0.00-100.00
  verification_details?: string;
  reviewed_by_agent_ids?: string; // JSON array

  created_at: string;
  updated_at: string;
}

// ============================================================================
// LLM Tracking Interfaces
// ============================================================================

/**
 * ILlmRequest - интерфейс для модели llm_requests
 * Отслеживание запросов к языковым моделям
 */
export interface ILlmRequest {
  id: number;
  agent_task_id?: number;
  provider: string; // openai, anthropic, deepseek, etc.
  model: string; // gpt-4, claude-3, etc.

  // Токены и стоимость
  prompt_tokens?: number;
  completion_tokens?: number;
  total_tokens?: number;
  cost?: number; // В долларах/рублях

  // Производительность
  response_time_ms?: number;
  status?: string; // success, error, timeout
  error_message?: string;

  // Данные запроса/ответа (для отладки)
  request_data?: string; // JSON
  response_data?: string; // JSON

  created_at: string;
  updated_at: string;
}

/**
 * ILlmUsageSummary - интерфейс для модели llm_usage_summaries
 * Агрегированная статистика использования LLM
 */
export interface ILlmUsageSummary {
  id: number;
  provider: string;
  model: string;
  date: string; // ISO date

  // Агрегированные метрики
  request_count: number; // default: 0
  total_tokens: number; // default: 0
  prompt_tokens: number; // default: 0
  completion_tokens: number; // default: 0
  total_cost: number; // default: 0.0
  error_count: number; // default: 0
  avg_response_time_ms?: number;

  created_at: string;
  updated_at: string;
}

// ============================================================================
// Process Automation Interfaces
// ============================================================================

/**
 * IProcess - интерфейс для модели processes
 * Представляет бизнес-процесс
 */
export interface IProcess {
  id: number;
  user_id: number;
  name: string;
  description?: string;
  status: 'draft' | 'active' | 'inactive' | 'archived'; // default: draft
  definition: Record<string, any>; // default: {}
  metadata: Record<string, any>; // default: {}
  version_number: number; // default: 1
  parent_id?: number; // Для версионирования
  created_at: string;
  updated_at: string;
}

/**
 * IProcessStep - интерфейс для модели process_steps
 * Представляет шаг в бизнес-процессе
 */
export interface IProcessStep {
  id: number;
  process_id: number;
  name: string;
  description?: string;
  step_type: string; // action, condition, loop, parallel, etc.
  order: number;
  next_step_id?: number;

  // Конфигурация шага
  configuration: Record<string, any>; // default: {}
  input_schema: Record<string, any>; // default: {}
  output_schema: Record<string, any>; // default: {}
  conditions: Record<string, any>; // default: {}

  created_at: string;
  updated_at: string;
}

/**
 * IProcessExecution - интерфейс для модели process_executions
 * Представляет исполнение процесса
 */
export interface IProcessExecution {
  id: number;
  process_id: number;
  user_id?: number;
  status: 'pending' | 'running' | 'completed' | 'failed' | 'cancelled'; // default: pending
  current_step_id?: number;

  // Данные и контекст
  input_data: Record<string, any>; // default: {}
  output_data: Record<string, any>; // default: {}
  context: Record<string, any>; // default: {}

  // Временные метки
  started_at?: string;
  completed_at?: string;
  error_message?: string;

  created_at: string;
  updated_at: string;
}

/**
 * IProcessStepExecution - интерфейс для модели process_step_executions
 * Представляет исполнение отдельного шага процесса
 */
export interface IProcessStepExecution {
  id: number;
  process_execution_id: number;
  process_step_id: number;
  status: 'pending' | 'running' | 'completed' | 'failed' | 'skipped'; // default: pending

  // Данные шага
  input_data: Record<string, any>; // default: {}
  output_data: Record<string, any>; // default: {}

  // Выполнение
  started_at?: string;
  completed_at?: string;
  retry_count: number; // default: 0
  error_message?: string;

  created_at: string;
  updated_at: string;
}

// ============================================================================
// Document Management Interfaces
// ============================================================================

/**
 * IDocument - интерфейс для модели documents
 * Представляет документ в системе
 */
export interface IDocument {
  id: number;
  user_id: number;
  title: string;
  description?: string;
  category: 'contract' | 'invoice' | 'report' | 'certificate' | 'other'; // default: 0 (contract)
  status: 'draft' | 'pending' | 'approved' | 'rejected' | 'archived'; // default: 0 (draft)
  classification?: string;

  // Контент
  content_text?: string;
  extracted_data?: Record<string, any>;
  metadata: Record<string, any>; // default: {}

  // Версионирование
  version?: string;
  version_number: number; // default: 1
  parent_id?: number;

  // Даты
  issue_date?: string;
  expiry_date?: string;

  created_at: string;
  updated_at: string;
}

/**
 * IReport - интерфейс для модели reports
 * Представляет отчет в системе
 */
export interface IReport {
  id: number;
  user_id: number;
  name: string;
  description?: string;
  report_type: string; // pdf, excel, dashboard, etc.
  status: 'active' | 'inactive' | 'generating' | 'error'; // default: 0 (active)

  // Параметры и планирование
  parameters: Record<string, any>; // default: {}
  schedule: Record<string, any>; // default: {} (cron expression, etc.)

  // Генерация
  last_generated_at?: string;
  next_generation_at?: string;

  created_at: string;
  updated_at: string;
}

// ============================================================================
// Integration Interfaces
// ============================================================================

/**
 * IIntegration - интерфейс для модели integrations
 * Представляет интеграцию с внешней системой
 */
export interface IIntegration {
  id: number;
  user_id: number;
  name: string;
  description?: string;
  integration_type: string; // api, webhook, ftp, database, etc.
  status: 'active' | 'inactive' | 'error' | 'testing'; // default: 0 (active)

  // Конфигурация
  configuration: Record<string, any>; // default: {}
  credentials: Record<string, any>; // default: {} (encrypted)

  // Синхронизация
  last_sync_at?: string;
  last_error?: string;

  created_at: string;
  updated_at: string;
}

/**
 * IIntegrationLog - интерфейс для модели integration_logs
 * Логи операций интеграции
 */
export interface IIntegrationLog {
  id: number;
  integration_id: number;
  operation: string; // sync, push, pull, test, etc.
  status: 'success' | 'partial' | 'failed'; // default: 0 (success)
  executed_at: string;
  duration?: number; // В секундах

  // Данные операции
  request_data: Record<string, any>; // default: {}
  response_data: Record<string, any>; // default: {}
  error_message?: string;

  created_at: string;
  updated_at: string;
}

// ============================================================================
// User Management Interfaces
// ============================================================================

/**
 * IUser - интерфейс для модели users
 * Представляет пользователя системы
 */
export interface IUser {
  id: number;
  name: string;
  email: string;
  password_digest: string; // bcrypt hash
  role: 'user' | 'operator' | 'admin' | 'superadmin'; // default: 0 (user)

  // Персональная информация
  first_name?: string;
  last_name?: string;

  // Для операторов
  license_number?: string;
  license_expiry?: string;
  total_flight_hours: number; // default: 0.0

  created_at: string;
  updated_at: string;
}

// ============================================================================
// Robot Management Interfaces
// ============================================================================

/**
 * IRobot - интерфейс для модели robots
 * Представляет роботизированную систему или ИИ-агента
 */
export interface IRobot {
  id: number;
  serial_number: string; // Уникальный
  registration_number?: string;
  manufacturer?: string;
  model?: string;
  status: 'active' | 'maintenance' | 'repair' | 'retired'; // default: 0 (active)

  // Технические характеристики
  specifications: Record<string, any>; // default: {}
  capabilities: Record<string, any>; // default: {}
  configuration: Record<string, any>; // default: {}

  // Метрики
  total_operation_hours: number; // default: 0.0
  total_tasks: number; // default: 0
  purchase_date?: string;
  last_maintenance_date?: string;

  created_at: string;
  updated_at: string;
}

/**
 * ITask - интерфейс для модели tasks
 * Представляет задание для робота или агента
 */
export interface ITask {
  id: number;
  robot_id: number;
  operator_id?: number;
  task_number: string; // Уникальный
  status: 'planned' | 'in_progress' | 'completed' | 'cancelled'; // default: 0 (planned)

  // Планирование
  planned_date?: string;
  actual_start?: string;
  actual_end?: string;
  duration?: number; // В минутах

  // Детали задания
  purpose?: string;
  location?: string;
  parameters: Record<string, any>; // default: {}
  context_data?: string;

  created_at: string;
  updated_at: string;
}

/**
 * IMaintenanceRecord - интерфейс для модели maintenance_records
 * Представляет запись о техническом обслуживании
 */
export interface IMaintenanceRecord {
  id: number;
  robot_id: number;
  technician_id?: number;
  maintenance_type: 'routine' | 'repair' | 'upgrade' | 'inspection'; // default: 0 (routine)
  status: 'scheduled' | 'in_progress' | 'completed' | 'cancelled'; // default: 0 (scheduled)

  // Планирование
  scheduled_date?: string;
  completed_date?: string;
  next_maintenance_date?: string;

  // Детали ТО
  description?: string;
  replaced_components: any[]; // default: []
  operation_hours_at_maintenance?: number;
  cost?: number;

  created_at: string;
  updated_at: string;
}

/**
 * ITelemetryData - интерфейс для модели telemetry_data
 * Представляет телеметрические данные от робота
 */
export interface ITelemetryData {
  id: number;
  robot_id: number;
  task_id?: number;
  recorded_at: string;

  // Геолокация
  latitude?: number;
  longitude?: number;
  altitude?: number;
  location?: string;

  // Данные
  data: Record<string, any>; // default: {}
  sensors: Record<string, any>; // default: {}

  created_at: string;
  updated_at: string;
}

/**
 * IInspectionReport - интерфейс для модели inspection_reports
 * Представляет отчет по инспекции
 */
export interface IInspectionReport {
  id: number;
  task_id: number;
  report_number: string; // Уникальный
  status: 'draft' | 'submitted' | 'reviewed' | 'approved'; // default: 0 (draft)

  // Детали инспекции
  inspection_date?: string;
  location?: string;
  coordinates?: string; // GPS координаты
  object_type?: string;

  // Результаты
  findings?: string;
  recommendations?: string;
  metadata: Record<string, any>; // default: {}

  created_at: string;
  updated_at: string;
}

// ============================================================================
// Analytics & Metrics Interfaces
// ============================================================================

/**
 * IMetric - интерфейс для модели metrics
 * Представляет метрику системы
 */
export interface IMetric {
  id: number;
  name: string;
  metric_type: string; // counter, gauge, histogram, etc.
  value?: number;
  labels: Record<string, any>; // default: {}
  metadata: Record<string, any>; // default: {}
  recorded_at: string;
  created_at: string;
  updated_at: string;
}

/**
 * IDashboard - интерфейс для модели dashboards
 * Представляет дашборд аналитики
 */
export interface IDashboard {
  id: number;
  user_id: number;
  name: string;
  description?: string;
  is_public: boolean; // default: false

  // Конфигурация
  widgets: any[]; // default: []
  configuration: Record<string, any>; // default: {}
  refresh_interval: number; // default: 60 (секунд)

  created_at: string;
  updated_at: string;
}

// ============================================================================
// Spreadsheet Interfaces (Google Sheets-like)
// ============================================================================

/**
 * ISpreadsheet - интерфейс для модели spreadsheets
 * Представляет электронную таблицу
 */
export interface ISpreadsheet {
  id: number;
  owner_id?: number;
  name: string;
  description?: string;
  public: boolean; // default: false
  share_token?: string; // Уникальный
  settings: Record<string, any>; // default: {}
  created_at: string;
  updated_at: string;
}

/**
 * ISheet - интерфейс для модели sheets
 * Представляет лист в электронной таблице
 */
export interface ISheet {
  id: number;
  spreadsheet_id: number;
  name: string;
  position: number; // default: 0
  column_definitions: any[]; // default: []
  settings: Record<string, any>; // default: {}
  created_at: string;
  updated_at: string;
}

/**
 * IRow - интерфейс для модели rows
 * Представляет строку в листе
 */
export interface IRow {
  id: number;
  sheet_id: number;
  position: number;
  data: Record<string, any>; // default: {}
  created_at: string;
  updated_at: string;
}

/**
 * ICell - интерфейс для модели cells
 * Представляет ячейку в листе
 */
export interface ICell {
  id: number;
  row_id: number;
  column_key: string;
  value?: string;
  data_type: string; // default: text (text, number, date, formula, etc.)
  formula?: string;
  metadata: Record<string, any>; // default: {}
  created_at: string;
  updated_at: string;
}

/**
 * ICollaborator - интерфейс для модели collaborators
 * Представляет соавтора таблицы
 */
export interface ICollaborator {
  id: number;
  spreadsheet_id: number;
  user_id?: number;
  email?: string;
  permission: 'view' | 'edit' | 'admin'; // default: view
  created_at: string;
  updated_at: string;
}

// ============================================================================
// Type Guards and Utility Types
// ============================================================================

/**
 * Тип для статусов выполнения
 */
export type ExecutionStatus =
  | 'pending'
  | 'running'
  | 'completed'
  | 'failed'
  | 'cancelled';

/**
 * Тип для ролей пользователей
 */
export type UserRole =
  | 'user'
  | 'operator'
  | 'admin'
  | 'superadmin';

/**
 * Тип для статусов агентов
 */
export type AgentStatus =
  | 'idle'
  | 'busy'
  | 'offline'
  | 'error';

/**
 * Базовый интерфейс для всех моделей с timestamps
 */
export interface ITimestamps {
  created_at: string;
  updated_at: string;
}

/**
 * Тип для пагинации
 */
export interface IPagination {
  page: number;
  per_page: number;
  total: number;
  total_pages: number;
}

/**
 * Ответ API с пагинацией
 */
export interface IPaginatedResponse<T> {
  data: T[];
  pagination: IPagination;
}
