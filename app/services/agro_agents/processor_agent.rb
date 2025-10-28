module AgroAgents
  # ProcessorAgent - Manages product processing and transformation
  class ProcessorAgent < BaseAgroAgent
    def execute_task(task)
      task.start!

      result = case task.task_type
               when 'execution'
                 execute_processing(task.input_data)
               when 'monitoring'
                 monitor_batches(task.input_data)
               when 'validation'
                 validate_quality(task.input_data)
               when 'analysis'
                 analyze_production(task.input_data)
               else
                 { status: 'error', message: 'Unknown task type' }
               end

      if result[:status] == 'success'
        task.complete!(result[:data])
      else
        task.fail!(result[:message])
      end

      log_execution(task, result)
      result
    rescue => e
      task.fail!(e.message)
      { status: 'error', message: e.message }
    end

    private

    def execute_processing(input)
      batch_data = input['batch']

      batch = agent.processing_batches.create!(
        batch_number: generate_batch_number,
        input_product: batch_data['input_product'],
        output_product: batch_data['output_product'],
        input_quantity: batch_data['input_quantity'],
        status: 'planned'
      )

      { status: 'success', data: { batch_id: batch.id, batch_number: batch.batch_number } }
    end

    def monitor_batches(input)
      active_batches = agent.processing_batches.active

      summary = {
        planned: active_batches.where(status: 'planned').count,
        processing: active_batches.where(status: 'processing').count,
        quality_check: active_batches.where(status: 'quality_check').count,
        total_active: active_batches.count
      }

      { status: 'success', data: summary }
    end

    def validate_quality(input)
      batch_id = input['batch_id']
      batch = agent.processing_batches.find_by(id: batch_id)

      return { status: 'error', message: 'Batch not found' } unless batch

      # Use LLM for quality assessment
      prompt = <<~PROMPT
        Оцените качество партии продукции:
        - Партия: #{batch.batch_number}
        - Продукт: #{batch.output_product}
        - Количество: #{batch.output_quantity}
        - Коэффициент конверсии: #{batch.conversion_rate}%

        Дайте оценку качества и рекомендации.
      PROMPT

      llm_response = ask_llm(prompt, batch.attributes)

      quality_data = {
        batch_id: batch.id,
        assessment: llm_response || 'Требуется ручная проверка',
        timestamp: Time.current
      }

      batch.update(
        status: 'quality_check',
        quality_metrics: quality_data
      )

      { status: 'success', data: quality_data }
    end

    def analyze_production(input)
      batches = agent.processing_batches.where(status: 'completed')

      return { status: 'success', data: { message: 'No completed batches' } } if batches.empty?

      conversion_rates = batches.map(&:conversion_rate).compact
      avg_conversion = conversion_rates.sum / conversion_rates.size if conversion_rates.any?

      analysis = {
        total_batches: batches.count,
        average_conversion_rate: avg_conversion&.round(2),
        total_output: batches.sum(:output_quantity)
      }

      { status: 'success', data: analysis }
    end

    def generate_batch_number
      "BATCH-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
    end
  end
end
