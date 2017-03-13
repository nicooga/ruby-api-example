require 'jwt'

class Api
  module Auth
    extend ActiveSupport::Concern

    included do |base|
      helpers HelperMethods
    end

    module HelperMethods
      def generate_token(user)
        JWT.encode({user_id: user.id}, SECRET, 'none')
      end

      def authenticate!
        return if current_user.present?
        raise Api::AuthenticationError.new('Authentication failed')
      end

      def current_user
        return unless (token_header = headers['Access-Token']).present?
        match = token_header.match(/(Bearer\s)?(.*)/)
        token = match && match[2]
        return unless token
        payload, _ = JWT.decode(token, SECRET, false)
        Api::Models::User.find id: payload.fetch('user_id')
      end
    end
  end
end
