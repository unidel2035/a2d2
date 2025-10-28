FactoryBot.define do
  factory :process_step do
    association :process
    name { "Test Step" }
    description { "A test process step" }
    step_type { "action" }
    order { 1 }
    configuration { { "action" => "test_action" } }
    input_schema { {} }
    output_schema { {} }
    conditions { {} }

    trait :agent_task do
      step_type { "agent_task" }
      configuration { { "agent_type" => "Agents::AnalyzerAgent", "task_params" => {} } }
    end

    trait :decision do
      step_type { "decision" }
      conditions { { "true" => "next_step_id", "false" => "other_step_id" } }
    end

    trait :integration do
      step_type { "integration" }
      configuration { { "integration_id" => "test_integration", "operation" => "fetch_data" } }
    end
  end
end
