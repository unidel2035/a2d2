module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      # TODO: Implement proper authentication when User model is ready
      # For now, return anonymous user
      OpenStruct.new(id: SecureRandom.uuid, email: 'anonymous@example.com')
    end
  end
end
