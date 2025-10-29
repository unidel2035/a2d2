# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_10_28_193016) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "agent_tasks", force: :cascade do |t|
    t.integer "agent_id"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "deadline_at"
    t.text "error_message"
    t.json "input_data"
    t.json "metadata", default: {}
    t.json "output_data"
    t.integer "priority", default: 5
    t.datetime "scheduled_at"
    t.datetime "started_at"
    t.string "status", default: "pending"
    t.string "task_type", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_agent_tasks_on_agent_id"
    t.index ["deadline_at"], name: "index_agent_tasks_on_deadline_at"
    t.index ["priority"], name: "index_agent_tasks_on_priority"
    t.index ["scheduled_at"], name: "index_agent_tasks_on_scheduled_at"
    t.index ["status"], name: "index_agent_tasks_on_status"
  end

  create_table "agents", force: :cascade do |t|
    t.json "capabilities", default: {}
    t.json "configuration", default: {}
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "last_heartbeat_at"
    t.string "name", null: false
    t.string "status", default: "idle"
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.string "version"
    t.index ["last_heartbeat_at"], name: "index_agents_on_last_heartbeat_at"
    t.index ["status"], name: "index_agents_on_status"
    t.index ["type"], name: "index_agents_on_type"
  end

  create_table "cells", force: :cascade do |t|
    t.string "column_key", null: false
    t.datetime "created_at", null: false
    t.string "data_type", default: "text"
    t.text "formula"
    t.json "metadata", default: {}
    t.integer "row_id", null: false
    t.datetime "updated_at", null: false
    t.text "value"
    t.index ["row_id", "column_key"], name: "index_cells_on_row_id_and_column_key", unique: true
    t.index ["row_id"], name: "index_cells_on_row_id"
  end

  create_table "collaborators", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "permission", default: "view"
    t.integer "spreadsheet_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["spreadsheet_id", "email"], name: "index_collaborators_on_spreadsheet_id_and_email", unique: true
    t.index ["spreadsheet_id", "user_id"], name: "index_collaborators_on_spreadsheet_id_and_user_id", unique: true
    t.index ["spreadsheet_id"], name: "index_collaborators_on_spreadsheet_id"
  end

  create_table "dashboards", force: :cascade do |t|
    t.json "configuration", default: {}
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "is_public", default: false
    t.string "name", null: false
    t.integer "refresh_interval", default: 60
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.json "widgets", default: []
    t.index ["is_public"], name: "index_dashboards_on_is_public"
    t.index ["name"], name: "index_dashboards_on_name"
    t.index ["user_id"], name: "index_dashboards_on_user_id"
  end

  create_table "documents", force: :cascade do |t|
    t.integer "category", default: 0, null: false
    t.string "classification"
    t.text "content_text"
    t.datetime "created_at", null: false
    t.text "description"
    t.date "expiry_date"
    t.json "extracted_data"
    t.date "issue_date"
    t.json "metadata", default: {}
    t.integer "parent_id"
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.string "version"
    t.integer "version_number", default: 1
    t.index ["category"], name: "index_documents_on_category"
    t.index ["classification"], name: "index_documents_on_classification"
    t.index ["created_at"], name: "index_documents_on_created_at"
    t.index ["parent_id"], name: "index_documents_on_parent_id"
    t.index ["status"], name: "index_documents_on_status"
    t.index ["user_id"], name: "index_documents_on_user_id"
  end

  create_table "inspection_reports", force: :cascade do |t|
    t.string "coordinates"
    t.datetime "created_at", null: false
    t.text "findings"
    t.date "inspection_date"
    t.string "location"
    t.json "metadata", default: {}
    t.string "object_type"
    t.text "recommendations"
    t.string "report_number", null: false
    t.integer "status", default: 0, null: false
    t.integer "task_id", null: false
    t.datetime "updated_at", null: false
    t.index ["inspection_date"], name: "index_inspection_reports_on_inspection_date"
    t.index ["report_number"], name: "index_inspection_reports_on_report_number", unique: true
    t.index ["status"], name: "index_inspection_reports_on_status"
    t.index ["task_id"], name: "index_inspection_reports_on_task_id"
  end

  create_table "integration_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.float "duration"
    t.text "error_message"
    t.datetime "executed_at", null: false
    t.integer "integration_id", null: false
    t.string "operation", null: false
    t.json "request_data", default: {}
    t.json "response_data", default: {}
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["integration_id", "executed_at"], name: "index_integration_logs_on_integration_id_and_executed_at"
    t.index ["integration_id"], name: "index_integration_logs_on_integration_id"
    t.index ["operation"], name: "index_integration_logs_on_operation"
    t.index ["status"], name: "index_integration_logs_on_status"
  end

  create_table "integrations", force: :cascade do |t|
    t.json "configuration", default: {}
    t.datetime "created_at", null: false
    t.json "credentials", default: {}
    t.text "description"
    t.string "integration_type", null: false
    t.text "last_error"
    t.datetime "last_sync_at"
    t.string "name", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["integration_type"], name: "index_integrations_on_integration_type"
    t.index ["name"], name: "index_integrations_on_name"
    t.index ["status"], name: "index_integrations_on_status"
    t.index ["user_id"], name: "index_integrations_on_user_id"
  end

  create_table "llm_requests", force: :cascade do |t|
    t.integer "agent_task_id"
    t.integer "completion_tokens"
    t.decimal "cost", precision: 10, scale: 6
    t.datetime "created_at", null: false
    t.text "error_message"
    t.string "model", null: false
    t.integer "prompt_tokens"
    t.string "provider", null: false
    t.json "request_data"
    t.json "response_data"
    t.integer "response_time_ms"
    t.string "status"
    t.integer "total_tokens"
    t.datetime "updated_at", null: false
    t.index ["agent_task_id"], name: "index_llm_requests_on_agent_task_id"
    t.index ["created_at"], name: "index_llm_requests_on_created_at"
    t.index ["model"], name: "index_llm_requests_on_model"
    t.index ["provider"], name: "index_llm_requests_on_provider"
    t.index ["status"], name: "index_llm_requests_on_status"
  end

  create_table "llm_usage_summaries", force: :cascade do |t|
    t.integer "avg_response_time_ms"
    t.bigint "completion_tokens", default: 0
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.integer "error_count", default: 0
    t.string "model", null: false
    t.bigint "prompt_tokens", default: 0
    t.string "provider", null: false
    t.integer "request_count", default: 0
    t.decimal "total_cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "total_tokens", default: 0
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_llm_usage_summaries_on_date"
    t.index ["provider", "model", "date"], name: "index_llm_usage_on_provider_model_date", unique: true
  end

  create_table "maintenance_records", force: :cascade do |t|
    t.date "completed_date"
    t.decimal "cost", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "maintenance_type", default: 0, null: false
    t.date "next_maintenance_date"
    t.decimal "operation_hours_at_maintenance", precision: 10, scale: 2
    t.json "replaced_components", default: []
    t.integer "robot_id", null: false
    t.date "scheduled_date"
    t.integer "status", default: 0, null: false
    t.integer "technician_id"
    t.datetime "updated_at", null: false
    t.index ["maintenance_type"], name: "index_maintenance_records_on_maintenance_type"
    t.index ["robot_id"], name: "index_maintenance_records_on_robot_id"
    t.index ["scheduled_date"], name: "index_maintenance_records_on_scheduled_date"
    t.index ["status"], name: "index_maintenance_records_on_status"
    t.index ["technician_id"], name: "index_maintenance_records_on_technician_id"
  end

  create_table "metrics", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.json "labels", default: {}
    t.json "metadata", default: {}
    t.string "metric_type", null: false
    t.string "name", null: false
    t.datetime "recorded_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "value", precision: 20, scale: 6
    t.index ["metric_type"], name: "index_metrics_on_metric_type"
    t.index ["name", "recorded_at"], name: "index_metrics_on_name_and_recorded_at"
    t.index ["name"], name: "index_metrics_on_name"
    t.index ["recorded_at"], name: "index_metrics_on_recorded_at"
  end

  create_table "process_executions", force: :cascade do |t|
    t.datetime "completed_at"
    t.json "context", default: {}
    t.datetime "created_at", null: false
    t.integer "current_step_id"
    t.text "error_message"
    t.json "input_data", default: {}
    t.json "output_data", default: {}
    t.integer "process_id", null: false
    t.datetime "started_at"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["completed_at"], name: "index_process_executions_on_completed_at"
    t.index ["process_id"], name: "index_process_executions_on_process_id"
    t.index ["started_at"], name: "index_process_executions_on_started_at"
    t.index ["status"], name: "index_process_executions_on_status"
    t.index ["user_id"], name: "index_process_executions_on_user_id"
  end

  create_table "process_step_executions", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.text "error_message"
    t.json "input_data", default: {}
    t.json "output_data", default: {}
    t.integer "process_execution_id", null: false
    t.integer "process_step_id", null: false
    t.integer "retry_count", default: 0
    t.datetime "started_at"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["process_execution_id", "created_at"], name: "idx_on_process_execution_id_created_at_27009f4f4a"
    t.index ["process_execution_id"], name: "index_process_step_executions_on_process_execution_id"
    t.index ["process_step_id"], name: "index_process_step_executions_on_process_step_id"
    t.index ["status"], name: "index_process_step_executions_on_status"
  end

  create_table "process_steps", force: :cascade do |t|
    t.json "conditions", default: {}
    t.json "configuration", default: {}
    t.datetime "created_at", null: false
    t.text "description"
    t.json "input_schema", default: {}
    t.string "name", null: false
    t.integer "next_step_id"
    t.integer "order", null: false
    t.json "output_schema", default: {}
    t.integer "process_id", null: false
    t.string "step_type", null: false
    t.datetime "updated_at", null: false
    t.index ["process_id", "order"], name: "index_process_steps_on_process_id_and_order"
    t.index ["process_id"], name: "index_process_steps_on_process_id"
    t.index ["step_type"], name: "index_process_steps_on_step_type"
  end

  create_table "processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.json "definition", default: {}
    t.text "description"
    t.json "metadata", default: {}
    t.string "name", null: false
    t.integer "parent_id"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "version_number", default: 1
    t.index ["name"], name: "index_processes_on_name"
    t.index ["parent_id"], name: "index_processes_on_parent_id"
    t.index ["status"], name: "index_processes_on_status"
    t.index ["user_id"], name: "index_processes_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "last_generated_at"
    t.string "name", null: false
    t.datetime "next_generation_at"
    t.json "parameters", default: {}
    t.string "report_type", null: false
    t.json "schedule", default: {}
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["next_generation_at"], name: "index_reports_on_next_generation_at"
    t.index ["report_type"], name: "index_reports_on_report_type"
    t.index ["status"], name: "index_reports_on_status"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "robots", force: :cascade do |t|
    t.json "capabilities", default: {}
    t.json "configuration", default: {}
    t.datetime "created_at", null: false
    t.date "last_maintenance_date"
    t.string "manufacturer"
    t.string "model"
    t.date "purchase_date"
    t.string "registration_number"
    t.string "serial_number"
    t.json "specifications", default: {}
    t.integer "status", default: 0, null: false
    t.decimal "total_operation_hours", precision: 10, scale: 2, default: "0.0"
    t.integer "total_tasks", default: 0
    t.datetime "updated_at", null: false
    t.index ["registration_number"], name: "index_robots_on_registration_number"
    t.index ["serial_number"], name: "index_robots_on_serial_number", unique: true
    t.index ["status"], name: "index_robots_on_status"
  end

  create_table "rows", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.json "data", default: {}
    t.integer "position", null: false
    t.integer "sheet_id", null: false
    t.datetime "updated_at", null: false
    t.index ["sheet_id", "position"], name: "index_rows_on_sheet_id_and_position"
    t.index ["sheet_id"], name: "index_rows_on_sheet_id"
  end

  create_table "sheets", force: :cascade do |t|
    t.json "column_definitions", default: []
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0
    t.json "settings", default: {}
    t.integer "spreadsheet_id", null: false
    t.datetime "updated_at", null: false
    t.index ["spreadsheet_id", "position"], name: "index_sheets_on_spreadsheet_id_and_position"
    t.index ["spreadsheet_id"], name: "index_sheets_on_spreadsheet_id"
  end

  create_table "spreadsheets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.integer "owner_id"
    t.boolean "public", default: false
    t.json "settings", default: {}
    t.string "share_token"
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_spreadsheets_on_owner_id"
    t.index ["share_token"], name: "index_spreadsheets_on_share_token", unique: true
  end

  create_table "tasks", force: :cascade do |t|
    t.datetime "actual_end"
    t.datetime "actual_start"
    t.text "context_data"
    t.datetime "created_at", null: false
    t.integer "duration"
    t.string "location"
    t.integer "operator_id"
    t.json "parameters", default: {}
    t.datetime "planned_date"
    t.string "purpose"
    t.integer "robot_id", null: false
    t.integer "status", default: 0, null: false
    t.string "task_number", null: false
    t.datetime "updated_at", null: false
    t.index ["operator_id"], name: "index_tasks_on_operator_id"
    t.index ["planned_date"], name: "index_tasks_on_planned_date"
    t.index ["robot_id"], name: "index_tasks_on_robot_id"
    t.index ["status"], name: "index_tasks_on_status"
    t.index ["task_number"], name: "index_tasks_on_task_number", unique: true
  end

  create_table "telemetry_data", force: :cascade do |t|
    t.decimal "altitude", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.json "data", default: {}
    t.decimal "latitude", precision: 10, scale: 6
    t.string "location"
    t.decimal "longitude", precision: 10, scale: 6
    t.datetime "recorded_at", null: false
    t.integer "robot_id", null: false
    t.json "sensors", default: {}
    t.integer "task_id"
    t.datetime "updated_at", null: false
    t.index ["recorded_at"], name: "index_telemetry_data_on_recorded_at"
    t.index ["robot_id", "recorded_at"], name: "index_telemetry_data_on_robot_id_and_recorded_at"
    t.index ["robot_id"], name: "index_telemetry_data_on_robot_id"
    t.index ["task_id"], name: "index_telemetry_data_on_task_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "encrypted_password"
    t.string "first_name"
    t.string "last_name"
    t.date "license_expiry"
    t.string "license_number"
    t.string "name", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.decimal "total_flight_hours", precision: 10, scale: 2, default: "0.0"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["license_number"], name: "index_users_on_license_number"
    t.index ["role"], name: "index_users_on_role"
  end

  create_table "workflow_connections", force: :cascade do |t|
    t.string "connection_type", default: "main"
    t.datetime "created_at", null: false
    t.integer "source_node_id", null: false
    t.integer "source_output_index", default: 0
    t.integer "target_input_index", default: 0
    t.integer "target_node_id", null: false
    t.datetime "updated_at", null: false
    t.integer "workflow_id", null: false
    t.index ["source_node_id", "target_node_id"], name: "idx_on_source_node_id_target_node_id_5e8435729f"
    t.index ["source_node_id"], name: "index_workflow_connections_on_source_node_id"
    t.index ["target_node_id"], name: "index_workflow_connections_on_target_node_id"
    t.index ["workflow_id"], name: "index_workflow_connections_on_workflow_id"
  end

  create_table "workflow_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "data"
    t.text "error_message"
    t.datetime "finished_at"
    t.string "mode"
    t.datetime "started_at"
    t.string "status", default: "new", null: false
    t.datetime "stopped_at"
    t.datetime "updated_at", null: false
    t.integer "workflow_id", null: false
    t.index ["started_at"], name: "index_workflow_executions_on_started_at"
    t.index ["status"], name: "index_workflow_executions_on_status"
    t.index ["workflow_id", "status"], name: "index_workflow_executions_on_workflow_id_and_status"
    t.index ["workflow_id"], name: "index_workflow_executions_on_workflow_id"
  end

  create_table "workflow_nodes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "credentials"
    t.string "name", null: false
    t.string "node_type", null: false
    t.text "parameters"
    t.text "position"
    t.integer "type_version", default: 1
    t.datetime "updated_at", null: false
    t.integer "workflow_id", null: false
    t.index ["node_type"], name: "index_workflow_nodes_on_node_type"
    t.index ["workflow_id", "name"], name: "index_workflow_nodes_on_workflow_id_and_name"
    t.index ["workflow_id"], name: "index_workflow_nodes_on_workflow_id"
  end

  create_table "workflows", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "project_id"
    t.text "settings"
    t.text "static_data"
    t.string "status", default: "inactive", null: false
    t.text "tags"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["name"], name: "index_workflows_on_name"
    t.index ["project_id"], name: "index_workflows_on_project_id"
    t.index ["status"], name: "index_workflows_on_status"
    t.index ["user_id"], name: "index_workflows_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "agent_tasks", "agents"
  add_foreign_key "cells", "rows"
  add_foreign_key "collaborators", "spreadsheets"
  add_foreign_key "dashboards", "users"
  add_foreign_key "documents", "users"
  add_foreign_key "inspection_reports", "tasks"
  add_foreign_key "integration_logs", "integrations"
  add_foreign_key "integrations", "users"
  add_foreign_key "llm_requests", "agent_tasks"
  add_foreign_key "maintenance_records", "robots"
  add_foreign_key "maintenance_records", "users", column: "technician_id"
  add_foreign_key "process_executions", "processes"
  add_foreign_key "process_executions", "users"
  add_foreign_key "process_step_executions", "process_executions"
  add_foreign_key "process_step_executions", "process_steps"
  add_foreign_key "process_steps", "processes"
  add_foreign_key "processes", "users"
  add_foreign_key "reports", "users"
  add_foreign_key "rows", "sheets"
  add_foreign_key "sheets", "spreadsheets"
  add_foreign_key "tasks", "robots"
  add_foreign_key "tasks", "users", column: "operator_id"
  add_foreign_key "telemetry_data", "robots"
  add_foreign_key "telemetry_data", "tasks"
  add_foreign_key "workflow_connections", "workflow_nodes", column: "source_node_id"
  add_foreign_key "workflow_connections", "workflow_nodes", column: "target_node_id"
  add_foreign_key "workflow_connections", "workflows"
  add_foreign_key "workflow_executions", "workflows"
  add_foreign_key "workflow_nodes", "workflows"
  add_foreign_key "workflows", "users"
end
