class Api
  module Entities
    class User < Grape::Entity
      expose :id
      expose :first_name, documentation: {required: true}
      expose :last_name, documentation: {required: true}
      expose :email, documentation: {required: true}
      expose :born_on
    end
  end
end
