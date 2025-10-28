module Agents
  class TransformerAgent < Agent
    def initialize(attributes = {})
      super
      self.type ||= "Agents::TransformerAgent"
      self.capabilities ||= {
        format_transformation: true,
        data_cleaning: true,
        normalization: true,
        enrichment: true,
        schema_mapping: true,
        batch_processing: true
      }
    end

    def execute(task)
      data = task.input_data["data"]
      transformation_type = task.input_data["transformation_type"]

      case transformation_type
      when "clean"
        clean_data(data)
      when "normalize"
        normalize_data(data, task.input_data["options"] || {})
      when "transform_format"
        transform_format(data, task.input_data["from_format"], task.input_data["to_format"])
      when "enrich"
        enrich_data(data, task.input_data["enrichment_source"])
      when "map_schema"
        map_schema(data, task.input_data["schema_mapping"])
      else
        { error: "Unknown transformation type: #{transformation_type}" }
      end
    end

    private

    def clean_data(data)
      case data
      when Array
        cleaned = data.compact.map do |item|
          clean_value(item)
        end
        { cleaned_data: cleaned, removed_count: data.size - cleaned.size }
      when Hash
        cleaned = data.transform_values { |v| clean_value(v) }
        { cleaned_data: cleaned }
      when String
        { cleaned_data: clean_string(data) }
      else
        { cleaned_data: data }
      end
    end

    def clean_value(value)
      case value
      when String
        clean_string(value)
      when Hash
        value.transform_values { |v| clean_value(v) }
      when Array
        value.map { |v| clean_value(v) }
      else
        value
      end
    end

    def clean_string(str)
      str.strip
        .gsub(/\s+/, " ") # Normalize whitespace
        .gsub(/[^\x00-\x7F]/) { |c| c } # Keep UTF-8 but could be configured
    end

    def normalize_data(data, options = {})
      method = options["method"] || "min_max"

      case data
      when Array
        numeric_data = data.select { |v| v.is_a?(Numeric) }
        return { error: "No numeric data to normalize" } if numeric_data.empty?

        normalized = case method
        when "min_max"
          min_max_normalize(numeric_data)
        when "z_score"
          z_score_normalize(numeric_data)
        else
          { error: "Unknown normalization method: #{method}" }
        end

        { normalized_data: normalized, method: method }
      else
        { error: "Data must be an array for normalization" }
      end
    end

    def min_max_normalize(data)
      min = data.min
      max = data.max
      range = max - min

      return data if range.zero?

      data.map { |v| ((v - min).to_f / range).round(4) }
    end

    def z_score_normalize(data)
      mean = data.sum.to_f / data.size
      std_dev = Math.sqrt(data.sum { |v| (v - mean)**2 } / data.size)

      return data if std_dev.zero?

      data.map { |v| ((v - mean) / std_dev).round(4) }
    end

    def transform_format(data, from_format, to_format)
      # Handle common format transformations
      case "#{from_format}_to_#{to_format}"
      when "json_to_csv"
        json_to_csv(data)
      when "csv_to_json"
        csv_to_json(data)
      when "xml_to_json"
        { error: "XML transformation not yet implemented" }
      else
        { error: "Unsupported format transformation: #{from_format} to #{to_format}" }
      end
    end

    def json_to_csv(data)
      return { error: "Data must be an array of hashes" } unless data.is_a?(Array) && data.first.is_a?(Hash)

      headers = data.first.keys
      csv_data = [ headers.join(",") ]
      data.each do |row|
        csv_data << headers.map { |h| row[h] }.join(",")
      end

      { csv_data: csv_data.join("\n"), row_count: data.size }
    end

    def csv_to_json(csv_string)
      lines = csv_string.split("\n")
      return { error: "CSV data is empty" } if lines.empty?

      headers = lines.first.split(",")
      data = lines[1..].map do |line|
        values = line.split(",")
        headers.zip(values).to_h
      end

      { json_data: data, row_count: data.size }
    end

    def enrich_data(data, source)
      # Placeholder for data enrichment from external sources
      # In real implementation, this would fetch from APIs, databases, etc.
      {
        enriched_data: data,
        enrichment_source: source,
        message: "Enrichment functionality to be implemented based on specific sources"
      }
    end

    def map_schema(data, schema_mapping)
      return { error: "Schema mapping must be provided" } unless schema_mapping.is_a?(Hash)

      case data
      when Hash
        mapped = {}
        schema_mapping.each do |target_field, source_field|
          mapped[target_field] = data[source_field]
        end
        { mapped_data: mapped }
      when Array
        mapped = data.map do |item|
          next item unless item.is_a?(Hash)

          result = {}
          schema_mapping.each do |target_field, source_field|
            result[target_field] = item[source_field]
          end
          result
        end
        { mapped_data: mapped }
      else
        { error: "Data must be a Hash or Array for schema mapping" }
      end
    end
  end
end
