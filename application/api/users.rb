class Api
  resource :users do
    params do
      includes :basic_search
    end

    get do
      users = SEQUEL_DB[:users].all
      {
        data: users
      }
    end

    post do
      attributes =
        permit_attributes(%i[
          first_name
          last_name
          email
          password
          born_on
        ])

      handling_validation(Api::Validators::User.new(attributes)) do
        user = Api::Models::User.new(attributes)
        user.save
        Api::Mailers::Users.creation_notification(user)
        user
      end
    end

    route_param(:id) do
      before { authenticate! }

      put do
        user = Api::Models::User.find id: params.fetch(:id)

        attributes =
          permit_attributes(%i[
            first_name
            last_name
            email
            password
            born_on
          ])

        new_attributes = user.values.merge(attributes)

        handling_validation(Api::Validators::User.new(new_attributes)) do
          user.update attributes
          user
        end
      end

      # For the sake of simplicity, I've used password instead of new_password param.
      patch(:reset_password) do
        user       = Api::Models::User.find id: params.fetch(:id)
        attributes = permit_attributes(%i[new_password new_password_confirmation])
        validation = Api::Validators::Password.new(attributes)

        handling_validation(validation) do
          user = Api::Models::User.find id: params.fetch(:id)
          user.update password: attributes.fetch(:new_password)
          user.reload
        end
      end
    end
  end
end
