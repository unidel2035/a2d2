module AgroAgents
  # LogisticsAgent - Manages transportation, delivery, and logistics
  class LogisticsAgent < BaseAgroAgent
    def execute_task(task)
      task.start!

      result = case task.task_type
               when 'coordination'
                 coordinate_delivery(task.input_data)
               when 'optimization'
                 optimize_route(task.input_data)
               when 'monitoring'
                 monitor_shipments(task.input_data)
               when 'analysis'
                 analyze_logistics_efficiency(task.input_data)
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

    def coordinate_delivery(input)
      order_data = input['order']

      order = agent.logistics_orders.create!(
        order_type: order_data['type'] || 'transport',
        origin: order_data['origin'],
        destination: order_data['destination'],
        quantity: order_data['quantity'],
        product_type: order_data['product_type'],
        status: 'pending'
      )

      { status: 'success', data: { order_id: order.id, status: order.status } }
    end

    def optimize_route(input)
      order_id = input['order_id']
      order = agent.logistics_orders.find_by(id: order_id)

      return { status: 'error', message: 'Order not found' } unless order

      # Use LLM for route optimization
      prompt = <<~PROMPT
        Оптимизируйте маршрут доставки:
        - Откуда: #{order.origin}
        - Куда: #{order.destination}
        - Груз: #{order.product_type}, #{order.quantity} тонн
        - Тип: #{order.order_type}

        Предложите оптимальный маршрут с учетом расстояния, времени и стоимости.
      PROMPT

      llm_response = ask_llm(prompt, order.attributes)

      optimized_route = llm_response || generate_basic_route(order)

      order.update(route_data: { optimized: true, route: optimized_route })

      { status: 'success', data: { route: optimized_route } }
    end

    def monitor_shipments(input)
      active_orders = agent.logistics_orders.active

      status_summary = {
        pending: active_orders.pending.count,
        in_transit: active_orders.in_transit.count,
        total_active: active_orders.count
      }

      alerts = []
      active_orders.each do |order|
        if order.pickup_time && order.pickup_time < Time.current
          alerts << "Order #{order.id} pickup time passed"
        end
      end

      { status: 'success', data: { summary: status_summary, alerts: alerts } }
    end

    def analyze_logistics_efficiency(input)
      completed_orders = agent.logistics_orders.where(status: 'delivered')
                              .where('delivery_time IS NOT NULL')

      return { status: 'success', data: { message: 'No completed orders' } } if completed_orders.empty?

      durations = completed_orders.map(&:duration).compact
      avg_duration = durations.sum / durations.size if durations.any?

      analysis = {
        total_deliveries: completed_orders.count,
        average_duration_hours: avg_duration ? (avg_duration / 3600).round(2) : nil,
        efficiency_rating: calculate_efficiency_rating(completed_orders)
      }

      { status: 'success', data: analysis }
    end

    def generate_basic_route(order)
      "Direct route from #{order.origin} to #{order.destination}"
    end

    def calculate_efficiency_rating(orders)
      # Simple efficiency calculation
      on_time = orders.count { |o| o.duration && o.duration < 24.hours }
      (on_time.to_f / orders.count * 100).round(2)
    end
  end
end
