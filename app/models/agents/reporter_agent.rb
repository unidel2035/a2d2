require "prawn"
require "prawn/table"

module Agents
  class ReporterAgent < Agent
    def initialize(attributes = {})
      super
      self.type ||= "Agents::ReporterAgent"
      self.capabilities ||= {
        pdf_generation: true,
        excel_generation: true,
        template_based_documents: true,
        chart_generation: true,
        scheduled_reporting: true
      }
    end

    def execute(task)
      data = task.input_data["data"]
      report_type = task.input_data["report_type"]
      format = task.input_data["format"] || "pdf"

      case format.downcase
      when "pdf"
        generate_pdf_report(data, report_type, task.input_data["options"] || {})
      when "excel"
        generate_excel_report(data, report_type, task.input_data["options"] || {})
      when "html"
        generate_html_report(data, report_type, task.input_data["options"] || {})
      else
        { error: "Unsupported report format: #{format}" }
      end
    end

    private

    def generate_pdf_report(data, report_type, options)
      pdf = Prawn::Document.new

      # Add title
      title = options["title"] || "Report"
      pdf.text title, size: 24, style: :bold, align: :center
      pdf.move_down 20

      # Add generation date
      pdf.text "Generated: #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}", size: 10, align: :right
      pdf.move_down 20

      case report_type
      when "table"
        add_table_to_pdf(pdf, data, options)
      when "summary"
        add_summary_to_pdf(pdf, data, options)
      when "detailed"
        add_detailed_report_to_pdf(pdf, data, options)
      else
        pdf.text "Unknown report type: #{report_type}"
      end

      # Add footer with page numbers
      pdf.number_pages "Page <page> of <total>", at: [ pdf.bounds.right - 100, 0 ], align: :right, size: 10

      # Save to temp file
      temp_file = Tempfile.new([ "report", ".pdf" ])
      pdf.render_file(temp_file.path)

      {
        success: true,
        file_path: temp_file.path,
        file_size: File.size(temp_file.path),
        format: "pdf"
      }
    rescue StandardError => e
      { error: "PDF generation failed: #{e.message}" }
    end

    def add_table_to_pdf(pdf, data, options)
      return unless data.is_a?(Array) && data.first.is_a?(Hash)

      headers = data.first.keys.map(&:to_s)
      rows = data.map { |row| headers.map { |h| row[h] || row[h.to_sym] } }

      pdf.table([ headers ] + rows, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = "DDDDDD"
        cells.padding = 5
        cells.borders = [ :top, :bottom ]
        cells.border_width = 0.5
      end
    end

    def add_summary_to_pdf(pdf, data, options)
      if data.is_a?(Hash)
        data.each do |key, value|
          pdf.text "#{key}: #{value}", size: 12
          pdf.move_down 5
        end
      elsif data.is_a?(Array)
        pdf.text "Total Records: #{data.size}", size: 14, style: :bold
        pdf.move_down 10

        # Add basic statistics if data is numeric
        numeric_data = data.select { |v| v.is_a?(Numeric) }
        if numeric_data.any?
          pdf.text "Sum: #{numeric_data.sum}", size: 12
          pdf.text "Average: #{(numeric_data.sum.to_f / numeric_data.size).round(2)}", size: 12
          pdf.text "Min: #{numeric_data.min}", size: 12
          pdf.text "Max: #{numeric_data.max}", size: 12
        end
      end
    end

    def add_detailed_report_to_pdf(pdf, data, options)
      if data.is_a?(Hash)
        data.each do |section, content|
          pdf.text section.to_s.humanize, size: 16, style: :bold
          pdf.move_down 10

          case content
          when Hash
            content.each do |key, value|
              pdf.text "  #{key}: #{value}", size: 11
              pdf.move_down 3
            end
          when Array
            content.each do |item|
              pdf.text "  • #{item}", size: 11
              pdf.move_down 3
            end
          else
            pdf.text "  #{content}", size: 11
          end

          pdf.move_down 15
        end
      end
    end

    def generate_excel_report(data, report_type, options)
      require "caxlsx"

      package = Axlsx::Package.new
      workbook = package.workbook

      # Add a worksheet
      workbook.add_worksheet(name: options["sheet_name"] || "Report") do |sheet|
        # Add title
        title = options["title"] || "Report"
        sheet.add_row [ title ], style: workbook.styles.add_style(sz: 16, b: true)
        sheet.add_row []

        # Add generation date
        sheet.add_row [ "Generated:", Time.current.strftime("%Y-%m-%d %H:%M:%S") ]
        sheet.add_row []

        case report_type
        when "table"
          add_table_to_excel(sheet, data, workbook)
        when "summary"
          add_summary_to_excel(sheet, data, workbook)
        when "detailed"
          add_detailed_to_excel(sheet, data, workbook)
        end
      end

      # Save to temp file
      temp_file = Tempfile.new([ "report", ".xlsx" ])
      package.serialize(temp_file.path)

      {
        success: true,
        file_path: temp_file.path,
        file_size: File.size(temp_file.path),
        format: "excel"
      }
    rescue StandardError => e
      { error: "Excel generation failed: #{e.message}" }
    end

    def add_table_to_excel(sheet, data, workbook)
      return unless data.is_a?(Array) && data.first.is_a?(Hash)

      header_style = workbook.styles.add_style(bg_color: "DDDDDD", b: true)

      # Add headers
      headers = data.first.keys.map(&:to_s)
      sheet.add_row headers, style: header_style

      # Add data rows
      data.each do |row|
        sheet.add_row headers.map { |h| row[h] || row[h.to_sym] }
      end
    end

    def add_summary_to_excel(sheet, data, workbook)
      bold_style = workbook.styles.add_style(b: true)

      if data.is_a?(Hash)
        data.each do |key, value|
          sheet.add_row [ key.to_s, value ]
        end
      elsif data.is_a?(Array)
        sheet.add_row [ "Total Records", data.size ], style: [ bold_style, nil ]

        numeric_data = data.select { |v| v.is_a?(Numeric) }
        if numeric_data.any?
          sheet.add_row []
          sheet.add_row [ "Sum", numeric_data.sum ]
          sheet.add_row [ "Average", (numeric_data.sum.to_f / numeric_data.size).round(2) ]
          sheet.add_row [ "Min", numeric_data.min ]
          sheet.add_row [ "Max", numeric_data.max ]
        end
      end
    end

    def add_detailed_to_excel(sheet, data, workbook)
      section_style = workbook.styles.add_style(sz: 14, b: true, bg_color: "EEEEEE")

      if data.is_a?(Hash)
        data.each do |section, content|
          sheet.add_row [ section.to_s.humanize ], style: section_style
          sheet.add_row []

          case content
          when Hash
            content.each do |key, value|
              sheet.add_row [ "  #{key}", value ]
            end
          when Array
            content.each do |item|
              sheet.add_row [ "  #{item}" ]
            end
          else
            sheet.add_row [ "  #{content}" ]
          end

          sheet.add_row []
        end
      end
    end

    def generate_html_report(data, report_type, options)
      html = <<~HTML
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <title>#{options['title'] || 'Report'}</title>
          <style>
            body { font-family: Arial, sans-serif; margin: 20px; }
            h1 { color: #333; }
            table { border-collapse: collapse; width: 100%; margin-top: 20px; }
            th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
            th { background-color: #4CAF50; color: white; }
            .summary { background-color: #f9f9f9; padding: 15px; border-radius: 5px; }
          </style>
        </head>
        <body>
          <h1>#{options['title'] || 'Report'}</h1>
          <p><em>Generated: #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}</em></p>
      HTML

      case report_type
      when "table"
        html += generate_html_table(data)
      when "summary"
        html += generate_html_summary(data)
      end

      html += "</body></html>"

      temp_file = Tempfile.new([ "report", ".html" ])
      File.write(temp_file.path, html)

      {
        success: true,
        file_path: temp_file.path,
        file_size: File.size(temp_file.path),
        format: "html"
      }
    rescue StandardError => e
      { error: "HTML generation failed: #{e.message}" }
    end

    def generate_html_table(data)
      return "<p>No table data available</p>" unless data.is_a?(Array) && data.first.is_a?(Hash)

      html = "<table><thead><tr>"
      headers = data.first.keys.map(&:to_s)
      headers.each { |h| html += "<th>#{h}</th>" }
      html += "</tr></thead><tbody>"

      data.each do |row|
        html += "<tr>"
        headers.each { |h| html += "<td>#{row[h] || row[h.to_sym]}</td>" }
        html += "</tr>"
      end

      html += "</tbody></table>"
      html
    end

    def generate_html_summary(data)
      html = "<div class='summary'>"
      if data.is_a?(Hash)
        data.each do |key, value|
          html += "<p><strong>#{key}:</strong> #{value}</p>"
        end
      end
      html += "</div>"
      html
    end
  end
end
