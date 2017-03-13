require 'hanami/validations'

# Forced to use a separate validator, because hanani doesn't support
# conditional validations, except through rules, which weren't working as documented
# See https://github.com/hanami/validations#rules
class Api
  module Validators
    class Password
      include Hanami::Validations

      validations do
        required(:new_password).filled.confirmation
      end
    end
  end
end
