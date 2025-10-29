# frozen_string_literal: true

# Current context for request-scoped attributes
# Used for storing current user and request in thread-safe way
class Current < ActiveSupport::CurrentAttributes
  attribute :user, :request
end
