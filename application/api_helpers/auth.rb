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

      def check_ability_to!(action, resource)
        return if current_user.abilities.can?(action, resource)
        raise Api::AuthorizationError.new('The authenticated user is not allowed to perform this action')
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
