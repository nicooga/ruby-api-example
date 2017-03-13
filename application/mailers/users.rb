require 'mail'

class Api
  module Mailers
    module Users
      def self.creation_notification(user)
        Mail.deliver do
          from SUPPORT_EMAIL
          to user.email
          subject "RubyTest: your account has been created"
          body "Hello #{user.full_name}, your account on RubyTest has been created"
        end
      end
    end
  end
end
