# frozen_string_literal: true

require "test_helper"

module Orchestration
  class TaskQueueManagerTest < ActiveSupport::TestCase
    setup do
      @agent = Agent.create!(
        name: "Test Agent",
        type: "Agents::AnalyzerAgent",
        status: "idle",
        capabilities: { test_task: true },
        last_heartbeat_at: Time.current
      )
    end

    test "should enqueue task" do
      task = TaskQueueManager.enqueue(
        task_type: "test_task",
        input_data: { test: "data" },
        priority: 7
      )

      assert task.persisted?
      assert_equal "test_task", task.task_type
      assert_equal 7, task.priority
      assert_equal "pending", task.status
    end

    test "should get next priority task" do
      TaskQueueManager.enqueue(
        task_type: "test_task",
        input_data: {},
        priority: 5
      )

      TaskQueueManager.enqueue(
        task_type: "test_task",
        input_data: {},
        priority: 8
      )

      next_task = TaskQueueManager.next_task(strategy: :priority_first)

      assert next_task.present?
      assert_equal 8, next_task.priority
    end

    test "should assign task to agent" do
      task = TaskQueueManager.enqueue(
        task_type: "test_task",
        input_data: {},
        priority: 5
      )

      result = TaskQueueManager.assign_task(task.id, strategy: :least_loaded)

      assert result.present?
      assert_equal task.id, result[:task].id
      assert_equal @agent.id, result[:agent].id
    end

    test "should retry failed tasks" do
      task = AgentTask.create!(
        task_type: "test_task",
        input_data: {},
        status: "failed",
        retry_count: 0,
        max_retries: 3
      )

      result = TaskQueueManager.retry_failed_tasks

      assert result[:retried_count] >= 0
    end

    test "should get queue stats" do
      stats = TaskQueueManager.queue_stats

      assert stats[:pending] >= 0
      assert stats[:processing] >= 0
      assert stats[:completed] >= 0
      assert stats[:failed] >= 0
    end

    test "should handle task timeout" do
      task = AgentTask.create!(
        agent: @agent,
        task_type: "test_task",
        input_data: {},
        status: "processing",
        started_at: Time.current
      )

      TaskQueueManager.handle_timeout(task.id)
      task.reload

      assert_equal "failed", task.status
    end
  end
end
