module AgroAgents
  # Base class for all agricultural agents
  class BaseAgroAgent
    attr_reader :agent, :llm_client

    def initialize(agent)
      @agent = agent
      @llm_client = LLM::Client.new
    end

    # Execute a task
    def execute_task(task)
      raise NotImplementedError, "#{self.class} must implement execute_task method"
    end

    # Check agent capabilities
    def can_handle?(task_type)
      agent.capability_list.include?(task_type.to_s)
    end

    # Update agent heartbeat
    def heartbeat!
      agent.heartbeat!
    end

    # Log task execution
    def log_execution(task, result)
      Rails.logger.info "[AgroAgent #{agent.id}] Task #{task.id}: #{result[:status]}"
    end

    protected

    # Use LLM for intelligent decision making
    def ask_llm(prompt, context = {})
      llm_client.chat(
        messages: [
          { role: 'system', content: system_prompt },
          { role: 'user', content: build_prompt(prompt, context) }
        ],
        temperature: 0.7
      )
    rescue => e
      Rails.logger.error "[AgroAgent #{agent.id}] LLM error: #{e.message}"
      nil
    end

    def system_prompt
      <<~PROMPT
        Вы - интеллектуальный агент в цифровой экосистеме АПК "Код Урожая".
        Ваш тип: #{agent.agent_type}
        Ваш уровень: #{agent.level}
        Ваши возможности: #{agent.capability_list.join(', ')}

        Ваша задача - принимать обоснованные решения на основе данных и координировать
        действия с другими агентами в экосистеме.

        Отвечайте кратко и структурированно в формате JSON.
      PROMPT
    end

    def build_prompt(prompt, context)
      prompt_text = prompt.to_s
      unless context.empty?
        prompt_text += "\n\nКонтекст:\n#{context.to_json}"
      end
      prompt_text
    end
  end
end
