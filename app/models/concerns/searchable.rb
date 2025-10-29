# frozen_string_literal: true

# Модуль для полнотекстового поиска с использованием SQLite
# Используется вместо pg_search для обеспечения совместимости с SQLite3
#
# Использование:
#   class Document < ApplicationRecord
#     include Searchable
#     SEARCHABLE_FIELDS = [:title, :content_text, :author]
#   end
#
#   Document.search("робот") # => Возвращает записи, содержащие "робот" в любом из указанных полей
#
module Searchable
  extend ActiveSupport::Concern

  included do
    # Проверяем, что модель определила поля для поиска
    unless const_defined?(:SEARCHABLE_FIELDS)
      raise "#{name} must define SEARCHABLE_FIELDS constant with array of searchable field names"
    end

    # Scope для поиска по нескольким полям
    # @param query [String] Строка поиска
    # @return [ActiveRecord::Relation] Результаты поиска
    scope :search, ->(query) {
      return all if query.blank?

      # Нормализуем запрос для поиска
      normalized_query = "%#{query.to_s.strip}%"

      # Получаем список полей для поиска
      searchable_fields = self::SEARCHABLE_FIELDS

      # Создаем условия для каждого поля
      conditions = searchable_fields.map do |field|
        sanitize_sql_array(["LOWER(#{table_name}.#{field}) LIKE LOWER(?)", normalized_query])
      end

      # Объединяем условия через OR
      where(conditions.join(" OR "))
    }
  end

  class_methods do
    # Продвинутый поиск с возможностью указать конкретные поля
    # @param query [String] Строка поиска
    # @param fields [Array<Symbol>] Конкретные поля для поиска (опционально)
    # @return [ActiveRecord::Relation] Результаты поиска
    def search_in_fields(query, fields: nil)
      return all if query.blank?

      fields ||= self::SEARCHABLE_FIELDS
      normalized_query = "%#{query.to_s.strip}%"

      conditions = fields.map do |field|
        unless self::SEARCHABLE_FIELDS.include?(field)
          raise ArgumentError, "Field #{field} is not in SEARCHABLE_FIELDS"
        end

        sanitize_sql_array(["LOWER(#{table_name}.#{field}) LIKE LOWER(?)", normalized_query])
      end

      where(conditions.join(" OR "))
    end

    # Точный поиск (без LIKE)
    # @param query [String] Строка для точного поиска
    # @param fields [Array<Symbol>] Конкретные поля для поиска (опционально)
    # @return [ActiveRecord::Relation] Результаты поиска
    def exact_search(query, fields: nil)
      return all if query.blank?

      fields ||= self::SEARCHABLE_FIELDS
      normalized_query = query.to_s.strip

      conditions = fields.map do |field|
        unless self::SEARCHABLE_FIELDS.include?(field)
          raise ArgumentError, "Field #{field} is not in SEARCHABLE_FIELDS"
        end

        sanitize_sql_array(["LOWER(#{table_name}.#{field}) = LOWER(?)", normalized_query])
      end

      where(conditions.join(" OR "))
    end
  end
end
