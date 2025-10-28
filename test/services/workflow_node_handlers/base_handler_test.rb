# frozen_string_literal: true

require 'test_helper'

class WorkflowNodeHandlers::BaseHandlerTest < ActiveSupport::TestCase
  def setup
    @handler = WorkflowNodeHandlers::BaseHandler.new
  end

  test 'should raise NotImplementedError for execute' do
    assert_raises(NotImplementedError) do
      @handler.execute({}, {}, {})
    end
  end

  test 'should safely dig nested data' do
    data = {
      'level1' => {
        'level2' => {
          'value' => 'test'
        }
      }
    }

    result = @handler.send(:safe_dig, data, 'level1', 'level2', 'value')
    assert_equal 'test', result
  end

  test 'should return nil for missing nested data' do
    data = { 'level1' => {} }

    result = @handler.send(:safe_dig, data, 'level1', 'missing', 'value')
    assert_nil result
  end

  test 'should evaluate simple expression' do
    data = { 'name' => 'John', 'age' => 30 }
    expression = 'Hello {{$json.name}}, you are {{$json.age}} years old'

    result = @handler.send(:evaluate_expression, expression, data)
    assert_equal 'Hello John, you are 30 years old', result
  end

  test 'should evaluate nested path' do
    data = {
      'user' => {
        'profile' => {
          'name' => 'Jane'
        }
      }
    }

    result = @handler.send(:evaluate_path, '$json.user.profile.name', data)
    assert_equal 'Jane', result
  end

  test 'should handle array access in path' do
    data = {
      'items' => [
        { 'id' => 1 },
        { 'id' => 2 }
      ]
    }

    result = @handler.send(:evaluate_path, '$json.items.0.id', data)
    assert_equal 1, result
  end
end
