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

ActiveRecord::Schema[8.1].define(version: 2025_10_28_210007) do
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
    t.string "assigned_strategy"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "deadline_at"
    t.text "dependencies"
    t.text "error_message"
    t.text "execution_context"
    t.json "input_data"
    t.integer "max_retries", default: 3
    t.json "metadata", default: {}
    t.json "output_data"
    t.integer "priority", default: 5
    t.decimal "quality_score", precision: 5, scale: 2
    t.integer "retry_count", default: 0
    t.text "reviewed_by_agent_ids"
    t.datetime "scheduled_at"
    t.datetime "started_at"
    t.string "status", default: "pending"
    t.string "task_type", null: false
    t.datetime "updated_at", null: false
    t.text "verification_details"
    t.string "verification_status"
    t.index ["agent_id"], name: "index_agent_tasks_on_agent_id"
    t.index ["deadline_at"], name: "index_agent_tasks_on_deadline_at"
    t.index ["priority"], name: "index_agent_tasks_on_priority"
    t.index ["quality_score"], name: "index_agent_tasks_on_quality_score"
    t.index ["retry_count"], name: "index_agent_tasks_on_retry_count"
    t.index ["scheduled_at"], name: "index_agent_tasks_on_scheduled_at"
    t.index ["status"], name: "index_agent_tasks_on_status"
    t.index ["verification_status"], name: "index_agent_tasks_on_verification_status"
  end

  create_table "agents", force: :cascade do |t|
    t.integer "average_completion_time", default: 0
    t.json "capabilities", default: {}
    t.json "configuration", default: {}
    t.datetime "created_at", null: false
    t.integer "current_task_count", default: 0
    t.text "description"
    t.integer "heartbeat_interval", default: 300
    t.datetime "last_heartbeat_at"
    t.integer "load_score", default: 0
    t.integer "max_concurrent_tasks", default: 5
    t.string "name", null: false
    t.text "performance_metrics"
    t.text "specialization_tags"
    t.string "status", default: "idle"
    t.decimal "success_rate", precision: 5, scale: 2, default: "100.0"
    t.integer "total_tasks_completed", default: 0
    t.integer "total_tasks_failed", default: 0
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.string "version"
    t.index ["last_heartbeat_at"], name: "index_agents_on_last_heartbeat_at"
    t.index ["load_score"], name: "index_agents_on_load_score"
    t.index ["status"], name: "index_agents_on_status"
    t.index ["success_rate"], name: "index_agents_on_success_rate"
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

  create_table "adaptive_agrotechnologies", force: :cascade do |t|
    t.text "adaptations"
    t.integer "agrotechnology_ontology_id", null: false
    t.datetime "created_at", null: false
    t.integer "crop_id"
    t.date "end_date"
    t.text "execution_plan"
    t.integer "farm_id", null: false
    t.integer "field_zone_id"
    t.string "name", null: false
    t.text "performance_metrics"
    t.date "start_date"
    t.string "status", default: "planned"
    t.datetime "updated_at", null: false
    t.index ["agrotechnology_ontology_id"], name: "index_adaptive_agrotechnologies_on_agrotechnology_ontology_id"
    t.index ["crop_id", "status"], name: "index_adaptive_agrotechnologies_on_crop_id_and_status"
    t.index ["farm_id", "status"], name: "index_adaptive_agrotechnologies_on_farm_id_and_status"
    t.index ["field_zone_id"], name: "index_adaptive_agrotechnologies_on_field_zone_id"
  end

  create_table "agent_collaborations", force: :cascade do |t|
    t.integer "agent_task_id", null: false
    t.string "collaboration_type"
    t.text "collaboration_metadata"
    t.datetime "completed_at"
    t.text "consensus_results"
    t.datetime "created_at", null: false
    t.text "participating_agent_ids"
    t.integer "primary_agent_id", null: false
    t.datetime "started_at"
    t.string "status", default: "pending"
    t.datetime "updated_at", null: false
    t.index ["agent_task_id"], name: "index_agent_collaborations_on_agent_task_id"
    t.index ["collaboration_type"], name: "index_agent_collaborations_on_collaboration_type"
    t.index ["primary_agent_id"], name: "index_agent_collaborations_on_primary_agent_id"
    t.index ["status"], name: "index_agent_collaborations_on_status"
  end

  create_table "agent_coordinations", force: :cascade do |t|
    t.datetime "completed_at"
    t.text "coordination_data"
    t.string "coordination_type", null: false
    t.datetime "created_at", null: false
    t.text "participating_agents"
    t.datetime "started_at"
    t.string "status", default: "active"
    t.datetime "updated_at", null: false
  end

  create_table "agro_agents", force: :cascade do |t|
    t.string "agent_type", null: false
    t.text "capabilities"
    t.text "configuration"
    t.datetime "created_at", null: false
    t.datetime "last_heartbeat"
    t.string "level", null: false
    t.string "name", null: false
    t.string "status", default: "active"
    t.float "success_rate", default: 100.0
    t.integer "tasks_completed", default: 0
    t.integer "tasks_failed", default: 0
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["agent_type"], name: "index_agro_agents_on_agent_type"
    t.index ["level"], name: "index_agro_agents_on_level"
    t.index ["status"], name: "index_agro_agents_on_status"
    t.index ["user_id"], name: "index_agro_agents_on_user_id"
  end

  create_table "agro_tasks", force: :cascade do |t|
    t.integer "agro_agent_id"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.text "error_message"
    t.text "input_data"
    t.text "output_data"
    t.string "priority", default: "normal"
    t.integer "retry_count", default: 0
    t.datetime "started_at"
    t.string "status", default: "pending"
    t.string "task_type", null: false
    t.datetime "updated_at", null: false
    t.index ["agro_agent_id"], name: "index_agro_tasks_on_agro_agent_id"
    t.index ["priority"], name: "index_agro_tasks_on_priority"
    t.index ["status"], name: "index_agro_tasks_on_status"
  end

  create_table "agrotechnology_ontologies", force: :cascade do |t|
    t.string "climate_zone"
    t.datetime "created_at", null: false
    t.string "crop_type", null: false
    t.text "description"
    t.boolean "is_template", default: true
    t.string "name", null: false
    t.text "ontology_data"
    t.integer "parent_ontology_id"
    t.string "soil_type"
    t.datetime "updated_at", null: false
    t.integer "version", default: 1
    t.index ["crop_type", "is_template"], name: "index_agrotechnology_ontologies_on_crop_type_and_is_template"
    t.index ["parent_ontology_id"], name: "index_agrotechnology_ontologies_on_parent_ontology_id"
  end

  create_table "agrotechnology_operations", force: :cascade do |t|
    t.integer "agrotechnology_ontology_id", null: false
    t.text "conditions"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "duration_days"
    t.text "equipment_requirements"
    t.text "material_requirements"
    t.string "name", null: false
    t.integer "operation_type", null: false
    t.text "parameters"
    t.string "quality_criteria"
    t.integer "sequence_order", null: false
    t.datetime "updated_at", null: false
    t.index ["agrotechnology_ontology_id", "sequence_order"], name: "idx_on_agrotechnology_ontology_id_sequence_order_e6e3e37b3d"
    t.index ["operation_type"], name: "index_agrotechnology_operations_on_operation_type"
  end

  create_table "agrotechnology_parameters", force: :cascade do |t|
    t.integer "agrotechnology_operation_id"
    t.string "application_method"
    t.datetime "created_at", null: false
    t.integer "field_zone_id"
    t.text "justification"
    t.string "parameter_name", null: false
    t.string "unit", null: false
    t.datetime "updated_at", null: false
    t.float "value", null: false
    t.index ["agrotechnology_operation_id"], name: "index_agrotechnology_parameters_on_agrotechnology_operation_id"
    t.index ["field_zone_id"], name: "index_agrotechnology_parameters_on_field_zone_id"
  end

  create_table "audit_logs", force: :cascade do |t|
    t.string "action", null: false
    t.bigint "auditable_id"
    t.string "auditable_type", null: false
    t.text "changes"
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.text "error_message"
    t.string "ip_address"
    t.text "metadata"
    t.string "previous_checksum"
    t.string "request_id"
    t.string "status"
    t.string "user_agent"
    t.integer "user_id"
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable_type_and_auditable_id"
    t.index ["checksum"], name: "index_audit_logs_on_checksum", unique: true
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "crops", force: :cascade do |t|
    t.float "actual_yield"
    t.float "area_planted"
    t.datetime "created_at", null: false
    t.string "crop_type", null: false
    t.float "expected_yield"
    t.integer "farm_id"
    t.date "harvest_date"
    t.date "planting_date"
    t.string "season"
    t.string "status", default: "planning"
    t.datetime "updated_at", null: false
    t.index ["farm_id"], name: "index_crops_on_farm_id"
    t.index ["status"], name: "index_crops_on_status"
  end

  create_table "decision_supports", force: :cascade do |t|
    t.integer "agro_agent_id"
    t.text "analysis_result"
    t.float "confidence_score"
    t.datetime "created_at", null: false
    t.integer "crop_id"
    t.string "decision_type", null: false
    t.datetime "executed_at"
    t.text "execution_result"
    t.integer "farm_id", null: false
    t.integer "field_zone_id"
    t.text "input_data"
    t.integer "priority", default: 2
    t.text "reasoning"
    t.datetime "recommended_execution_date"
    t.text "recommendations"
    t.string "status", default: "pending"
    t.datetime "updated_at", null: false
    t.index ["agro_agent_id"], name: "index_decision_supports_on_agro_agent_id"
    t.index ["crop_id"], name: "index_decision_supports_on_crop_id"
    t.index ["decision_type", "status"], name: "index_decision_supports_on_decision_type_and_status"
    t.index ["farm_id", "status"], name: "index_decision_supports_on_farm_id_and_status"
    t.index ["field_zone_id"], name: "index_decision_supports_on_field_zone_id"
    t.index ["recommended_execution_date"], name: "index_decision_supports_on_recommended_execution_date"
  end

  create_table "equipment", force: :cascade do |t|
    t.boolean "autonomous", default: false
    t.datetime "created_at", null: false
    t.string "equipment_type"
    t.integer "farm_id"
    t.datetime "last_telemetry_at"
    t.string "model"
    t.string "name", null: false
    t.string "status", default: "available"
    t.text "telemetry_data"
    t.datetime "updated_at", null: false
    t.index ["farm_id"], name: "index_equipment_on_farm_id"
    t.index ["status"], name: "index_equipment_on_status"
  end

  create_table "farms", force: :cascade do |t|
    t.integer "agro_agent_id"
    t.float "area"
    t.text "coordinates"
    t.datetime "created_at", null: false
    t.string "farm_type"
    t.string "location"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["agro_agent_id"], name: "index_farms_on_agro_agent_id"
    t.index ["user_id"], name: "index_farms_on_user_id"
  end

  create_table "field_zones", force: :cascade do |t|
    t.float "area"
    t.text "characteristics"
    t.datetime "created_at", null: false
    t.float "elevation"
    t.integer "farm_id", null: false
    t.text "geometry"
    t.string "name", null: false
    t.string "productivity_class"
    t.string "soil_type"
    t.datetime "updated_at", null: false
    t.index ["farm_id", "productivity_class"], name: "index_field_zones_on_farm_id_and_productivity_class"
  end

  create_table "knowledge_base_entries", force: :cascade do |t|
    t.text "applicability_conditions"
    t.string "category", null: false
    t.integer "confidence_level", default: 5
    t.text "content"
    t.datetime "created_at", null: false
    t.string "entry_type", null: false
    t.string "language", default: "ru"
    t.text "ontology_link"
    t.text "related_concepts"
    t.string "source"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["category", "entry_type"], name: "index_knowledge_base_entries_on_category_and_entry_type"
  end

  create_table "logistics_orders", force: :cascade do |t|
    t.integer "agro_agent_id"
    t.datetime "created_at", null: false
    t.datetime "delivery_time"
    t.text "destination"
    t.string "order_type", null: false
    t.text "origin"
    t.datetime "pickup_time"
    t.string "product_type"
    t.float "quantity"
    t.text "route_data"
    t.string "status", default: "pending"
    t.datetime "updated_at", null: false
    t.index ["agro_agent_id"], name: "index_logistics_orders_on_agro_agent_id"
    t.index ["status"], name: "index_logistics_orders_on_status"
  end

  create_table "market_offers", force: :cascade do |t|
    t.integer "agro_agent_id"
    t.text "conditions"
    t.datetime "created_at", null: false
    t.string "offer_type", null: false
    t.decimal "price_per_unit", precision: 10, scale: 2
    t.string "product_type", null: false
    t.float "quantity"
    t.string "status", default: "active"
    t.string "unit"
    t.datetime "updated_at", null: false
    t.date "valid_until"
    t.index ["agro_agent_id"], name: "index_market_offers_on_agro_agent_id"
    t.index ["status"], name: "index_market_offers_on_status"
  end

  create_table "orchestrator_events", force: :cascade do |t|
    t.integer "agent_id"
    t.integer "agent_task_id"
    t.datetime "created_at", null: false
    t.text "event_data"
    t.string "event_type", null: false
    t.text "message"
    t.datetime "occurred_at", null: false
    t.string "severity"
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_orchestrator_events_on_agent_id"
    t.index ["agent_task_id"], name: "index_orchestrator_events_on_agent_task_id"
    t.index ["event_type"], name: "index_orchestrator_events_on_event_type"
    t.index ["occurred_at"], name: "index_orchestrator_events_on_occurred_at"
    t.index ["severity"], name: "index_orchestrator_events_on_severity"
  end

  create_table "permissions", force: :cascade do |t|
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.string "name", null: false
    t.string "resource", null: false
    t.datetime "updated_at", null: false
    t.index ["resource", "action"], name: "index_permissions_on_resource_and_action", unique: true
  end

  create_table "plant_production_models", force: :cascade do |t|
    t.integer "agrotechnology_ontology_id"
    t.float "confidence_level"
    t.datetime "created_at", null: false
    t.integer "crop_id", null: false
    t.integer "field_zone_id"
    t.date "harvest_date_prediction"
    t.text "management_practices"
    t.text "model_parameters"
    t.string "model_type", null: false
    t.string "model_version"
    t.text "plant_state"
    t.datetime "prediction_date"
    t.float "predicted_quality"
    t.float "predicted_yield"
    t.text "soil_parameters"
    t.datetime "updated_at", null: false
    t.text "weather_data"
    t.index ["agrotechnology_ontology_id"], name: "index_plant_production_models_on_agrotechnology_ontology_id"
    t.index ["crop_id", "prediction_date"], name: "index_plant_production_models_on_crop_id_and_prediction_date"
    t.index ["field_zone_id"], name: "index_plant_production_models_on_field_zone_id"
  end

  create_table "processing_batches", force: :cascade do |t|
    t.integer "agro_agent_id"
    t.string "batch_number", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.string "input_product"
    t.float "input_quantity"
    t.string "output_product"
    t.float "output_quantity"
    t.text "quality_metrics"
    t.datetime "started_at"
    t.string "status", default: "planned"
    t.datetime "updated_at", null: false
    t.index ["agro_agent_id"], name: "index_processing_batches_on_agro_agent_id"
    t.index ["status"], name: "index_processing_batches_on_status"
  end

  create_table "remote_sensing_data", force: :cascade do |t|
    t.datetime "captured_at", null: false
    t.float "confidence_score"
    t.datetime "created_at", null: false
    t.integer "crop_id"
    t.text "data"
    t.integer "data_type", null: false
    t.integer "farm_id"
    t.integer "field_zone_id"
    t.text "metadata"
    t.float "ndvi_value"
    t.string "source_name"
    t.integer "source_type", null: false
    t.datetime "updated_at", null: false
    t.index ["crop_id", "data_type"], name: "index_remote_sensing_data_on_crop_id_and_data_type"
    t.index ["farm_id", "captured_at"], name: "index_remote_sensing_data_on_farm_id_and_captured_at"
    t.index ["field_zone_id"], name: "index_remote_sensing_data_on_field_zone_id"
    t.index ["source_type", "captured_at"], name: "index_remote_sensing_data_on_source_type_and_captured_at"
  end

  create_table "risk_assessments", force: :cascade do |t|
    t.date "assessment_date"
    t.datetime "created_at", null: false
    t.integer "crop_id"
    t.integer "decision_support_id"
    t.integer "farm_id", null: false
    t.float "impact_score"
    t.boolean "is_active", default: true
    t.text "mitigation_strategies"
    t.float "probability"
    t.text "risk_description"
    t.string "risk_type", null: false
    t.string "severity", null: false
    t.datetime "updated_at", null: false
    t.index ["crop_id"], name: "index_risk_assessments_on_crop_id"
    t.index ["decision_support_id"], name: "index_risk_assessments_on_decision_support_id"
    t.index ["farm_id", "is_active"], name: "index_risk_assessments_on_farm_id_and_is_active"
    t.index ["severity", "is_active"], name: "index_risk_assessments_on_severity_and_is_active"
  end

  create_table "role_permissions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "permission_id", null: false
    t.integer "role_id", null: false
    t.datetime "updated_at", null: false
    t.index ["permission_id"], name: "index_role_permissions_on_permission_id"
    t.index ["role_id", "permission_id"], name: "index_role_permissions_on_role_id_and_permission_id", unique: true
    t.index ["role_id"], name: "index_role_permissions_on_role_id"
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "simulation_results", force: :cascade do |t|
    t.integer "adaptive_agrotechnology_id"
    t.datetime "created_at", null: false
    t.integer "crop_id"
    t.float "economic_benefit"
    t.float "environmental_impact_score"
    t.integer "farm_id", null: false
    t.float "predicted_outcome"
    t.string "recommendation_summary"
    t.text "scenario_parameters"
    t.text "simulation_data"
    t.string "simulation_type", null: false
    t.datetime "simulated_at"
    t.datetime "updated_at", null: false
    t.index ["adaptive_agrotechnology_id"], name: "index_simulation_results_on_adaptive_agrotechnology_id"
    t.index ["crop_id"], name: "index_simulation_results_on_crop_id"
    t.index ["farm_id", "simulation_type"], name: "index_simulation_results_on_farm_id_and_simulation_type"
  end

  create_table "smart_contracts", force: :cascade do |t|
    t.integer "buyer_agent_id"
    t.date "completion_date"
    t.string "contract_type", null: false
    t.datetime "created_at", null: false
    t.date "execution_date"
    t.text "fulfillment_data"
    t.integer "seller_agent_id"
    t.string "status", default: "draft"
    t.text "terms"
    t.decimal "total_amount", precision: 12, scale: 2
    t.datetime "updated_at", null: false
    t.index ["buyer_agent_id"], name: "index_smart_contracts_on_buyer_agent_id"
    t.index ["seller_agent_id"], name: "index_smart_contracts_on_seller_agent_id"
    t.index ["status"], name: "index_smart_contracts_on_status"
  end

  create_table "user_roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "role_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id", unique: true
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "weather_data", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "farm_id"
    t.integer "field_zone_id"
    t.text "forecast_data"
    t.float "humidity"
    t.float "precipitation"
    t.datetime "recorded_at", null: false
    t.float "solar_radiation"
    t.float "soil_moisture"
    t.float "soil_temperature"
    t.string "source"
    t.float "temperature"
    t.datetime "updated_at", null: false
    t.integer "wind_direction"
    t.float "wind_speed"
    t.index ["farm_id", "recorded_at"], name: "index_weather_data_on_farm_id_and_recorded_at"
    t.index ["field_zone_id"], name: "index_weather_data_on_field_zone_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "api_token"
    t.datetime "api_token_created_at"
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.boolean "data_processing_consent", default: false, null: false
    t.datetime "data_processing_consent_at"
    t.string "email", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.date "license_expiry"
    t.string "license_number"
    t.datetime "locked_at"
    t.string "name", null: false
    t.text "otp_backup_codes"
    t.boolean "otp_required_for_login", default: false, null: false
    t.string "otp_secret"
    t.datetime "privacy_policy_accepted_at"
    t.datetime "remember_created_at"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer "role", default: 0, null: false
    t.string "session_token"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "terms_of_service_accepted_at"
    t.decimal "total_flight_hours", precision: 10, scale: 2, default: "0.0"
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["license_number"], name: "index_users_on_license_number"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["session_token"], name: "index_users_on_session_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
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
  add_foreign_key "adaptive_agrotechnologies", "agrotechnology_ontologies"
  add_foreign_key "adaptive_agrotechnologies", "crops"
  add_foreign_key "adaptive_agrotechnologies", "farms"
  add_foreign_key "adaptive_agrotechnologies", "field_zones"
  add_foreign_key "agent_collaborations", "agent_tasks"
  add_foreign_key "agent_collaborations", "agents", column: "primary_agent_id"
  add_foreign_key "agent_tasks", "agents"
  add_foreign_key "agro_agents", "users"
  add_foreign_key "agro_tasks", "agro_agents"
  add_foreign_key "agrotechnology_ontologies", "agrotechnology_ontologies", column: "parent_ontology_id"
  add_foreign_key "agrotechnology_operations", "agrotechnology_ontologies"
  add_foreign_key "agrotechnology_parameters", "agrotechnology_operations"
  add_foreign_key "agrotechnology_parameters", "field_zones"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "cells", "rows"
  add_foreign_key "collaborators", "spreadsheets"
  add_foreign_key "crops", "farms"
  add_foreign_key "dashboards", "users"
  add_foreign_key "decision_supports", "agro_agents"
  add_foreign_key "decision_supports", "crops"
  add_foreign_key "decision_supports", "farms"
  add_foreign_key "decision_supports", "field_zones"
  add_foreign_key "documents", "users"
  add_foreign_key "equipment", "farms"
  add_foreign_key "farms", "agro_agents"
  add_foreign_key "farms", "users"
  add_foreign_key "field_zones", "farms"
  add_foreign_key "inspection_reports", "tasks"
  add_foreign_key "integration_logs", "integrations"
  add_foreign_key "integrations", "users"
  add_foreign_key "llm_requests", "agent_tasks"
  add_foreign_key "logistics_orders", "agro_agents"
  add_foreign_key "maintenance_records", "robots"
  add_foreign_key "maintenance_records", "users", column: "technician_id"
  add_foreign_key "market_offers", "agro_agents"
  add_foreign_key "orchestrator_events", "agent_tasks"
  add_foreign_key "orchestrator_events", "agents"
  add_foreign_key "plant_production_models", "agrotechnology_ontologies"
  add_foreign_key "plant_production_models", "crops"
  add_foreign_key "plant_production_models", "field_zones"
  add_foreign_key "process_executions", "processes"
  add_foreign_key "process_executions", "users"
  add_foreign_key "process_step_executions", "process_executions"
  add_foreign_key "process_step_executions", "process_steps"
  add_foreign_key "process_steps", "processes"
  add_foreign_key "processes", "users"
  add_foreign_key "processing_batches", "agro_agents"
  add_foreign_key "remote_sensing_data", "crops"
  add_foreign_key "remote_sensing_data", "farms"
  add_foreign_key "remote_sensing_data", "field_zones"
  add_foreign_key "reports", "users"
  add_foreign_key "risk_assessments", "crops"
  add_foreign_key "risk_assessments", "decision_supports"
  add_foreign_key "risk_assessments", "farms"
  add_foreign_key "role_permissions", "permissions"
  add_foreign_key "role_permissions", "roles"
  add_foreign_key "rows", "sheets"
  add_foreign_key "sheets", "spreadsheets"
  add_foreign_key "simulation_results", "adaptive_agrotechnologies"
  add_foreign_key "simulation_results", "crops"
  add_foreign_key "simulation_results", "farms"
  add_foreign_key "smart_contracts", "agro_agents", column: "buyer_agent_id"
  add_foreign_key "smart_contracts", "agro_agents", column: "seller_agent_id"
  add_foreign_key "tasks", "robots"
  add_foreign_key "tasks", "users", column: "operator_id"
  add_foreign_key "telemetry_data", "robots"
  add_foreign_key "telemetry_data", "tasks"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
  add_foreign_key "weather_data", "farms"
  add_foreign_key "weather_data", "field_zones"
  add_foreign_key "workflow_connections", "workflow_nodes", column: "source_node_id"
  add_foreign_key "workflow_connections", "workflow_nodes", column: "target_node_id"
  add_foreign_key "workflow_connections", "workflows"
  add_foreign_key "workflow_executions", "workflows"
  add_foreign_key "workflow_nodes", "workflows"
  add_foreign_key "workflows", "users"
end
