#!/usr/bin/env ruby
# frozen_string_literal: true

# Скрипт для генерации TypeScript интерфейсов из Rails моделей
# Использование: ruby script/generate_typescript_interfaces.rb

require 'json'
require 'yaml'

# Конфигурация маппинга типов Ruby/Rails -> TypeScript
TYPE_MAPPING = {
  'integer' => 'number',
  'bigint' => 'number',
  'float' => 'number',
  'decimal' => 'number',
  'string' => 'string',
  'text' => 'string',
  'boolean' => 'boolean',
  'date' => 'string', # ISO date format
  'datetime' => 'string', # ISO datetime format
  'time' => 'string',
  'json' => 'Record<string, any>',
  'jsonb' => 'Record<string, any>',
  'array' => 'any[]'
}.freeze

class TypeScriptInterfaceGenerator
  attr_reader :schema_path, :models_path, :output_path

  def initialize
    @schema_path = File.join(__dir__, '..', 'db', 'schema.rb')
    @models_path = File.join(__dir__, '..', 'app', 'models')
    @output_path = File.join(__dir__, '..', 'experiments', 'n8ndd-interfaces', 'a2d2-interfaces.ts')
  end

  def generate
    puts "🔍 Читаю схему базы данных из #{schema_path}..."
    tables = parse_schema

    puts "📝 Генерирую TypeScript интерфейсы..."
    interfaces = generate_interfaces(tables)

    puts "💾 Сохраняю интерфейсы в #{output_path}..."
    save_interfaces(interfaces)

    puts "✅ Генерация завершена успешно!"
    puts "📊 Сгенерировано интерфейсов: #{interfaces.size}"
  end

  private

  def parse_schema
    schema_content = File.read(schema_path)
    tables = {}
    current_table = nil
    current_columns = []

    schema_content.each_line do |line|
      # Начало определения таблицы
      if line.match(/create_table\s+"([^"]+)"/)
        current_table = Regexp.last_match(1)
        current_columns = []
      # Определение колонки
      elsif current_table && line.match(/t\.(integer|string|text|datetime|date|boolean|decimal|float|bigint|json)\s+"([^"]+)"(.*)/)
        column_type = Regexp.last_match(1)
        column_name = Regexp.last_match(2)
        options = Regexp.last_match(3)

        nullable = !options.include?('null: false')
        default_value = extract_default(options)

        current_columns << {
          name: column_name,
          type: column_type,
          nullable: nullable,
          default: default_value
        }
      # Конец определения таблицы
      elsif line.match(/^\s+end\s*$/) && current_table
        tables[current_table] = current_columns
        current_table = nil
        current_columns = []
      end
    end

    tables
  end

  def extract_default(options_string)
    if options_string.match(/default:\s*"([^"]*)"/)
      Regexp.last_match(1)
    elsif options_string.match(/default:\s*(\d+)/)
      Regexp.last_match(1)
    elsif options_string.match(/default:\s*(true|false)/)
      Regexp.last_match(1)
    elsif options_string.match(/default:\s*\[\]/)
      '[]'
    elsif options_string.match(/default:\s*\{\}/)
      '{}'
    else
      nil
    end
  end

  def generate_interfaces(tables)
    interfaces = {}

    # Фокусируемся на основных моделях системы
    priority_tables = %w[
      workflows workflow_nodes workflow_connections workflow_executions
      agents agent_tasks
      processes process_steps process_executions process_step_executions
      documents reports integrations
      users robots tasks
    ]

    priority_tables.each do |table_name|
      next unless tables[table_name]

      interface_name = table_name_to_interface_name(table_name)
      columns = tables[table_name]

      interfaces[interface_name] = generate_interface(interface_name, columns, table_name)
    end

    interfaces
  end

  def table_name_to_interface_name(table_name)
    # workflows -> IWorkflow
    # workflow_nodes -> IWorkflowNode
    singular = table_name.sub(/_id$/, '')
    parts = singular.split('_').map(&:capitalize)
    "I#{parts.join('')}"
  end

  def generate_interface(interface_name, columns, table_name)
    lines = []
    lines << "/**"
    lines << " * #{interface_name} - интерфейс для модели #{table_name}"
    lines << " * Автоматически сгенерировано из схемы Rails БД"
    lines << " * @generated #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    lines << " */"
    lines << "export interface #{interface_name} {"

    columns.each do |column|
      ts_type = map_type(column[:type])
      optional = column[:nullable] ? '?' : ''
      comment = column[:default] ? " // default: #{column[:default]}" : ""

      lines << "  #{column[:name]}#{optional}: #{ts_type};#{comment}"
    end

    lines << "}"
    lines << ""

    lines.join("\n")
  end

  def map_type(rails_type)
    TYPE_MAPPING[rails_type] || 'any'
  end

  def save_interfaces(interfaces)
    content = generate_file_header + interfaces.values.join("\n")
    File.write(output_path, content)
  end

  def generate_file_header
    <<~HEADER
      /**
       * A2D2 TypeScript Interfaces
       * Автоматически сгенерированные интерфейсы из Rails моделей
       *
       * Этот файл содержит TypeScript интерфейсы для всех основных моделей системы A2D2.
       * Интерфейсы синхронизированы со схемой базы данных Rails.
       *
       * @package A2D2
       * @version 1.0.0
       * @generated #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}
       *
       * ВНИМАНИЕ: Этот файл генерируется автоматически.
       * Не редактируйте его вручную - изменения будут перезаписаны.
       * Для обновления интерфейсов используйте: ruby script/generate_typescript_interfaces.rb
       */

      // ============================================================================
      // Workflow System Interfaces (n8n-compatible)
      // ============================================================================

    HEADER
  end
end

# Запуск генератора
if __FILE__ == $PROGRAM_NAME
  generator = TypeScriptInterfaceGenerator.new
  generator.generate
end
