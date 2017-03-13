require 'hanami/validations'

class Api
  module Validators
    class User
      include Hanami::Validations::Form

      DATE_TIME_REGEX = /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:[\d\.]+(Z|((\+|-)\d{2}:\d{2}))/

      validations do
        required(:first_name) { filled? & str? }
        required(:last_name)  { filled? & str? }
        required(:email)      { filled? & str? }
        required(:password)   { filled? & str? }
        # Validate date is either an ISO861 string or a date object
        optional(:born_on)    { str? > format?(DATE_TIME_REGEX) | date? }
      end
    end
  end
end
