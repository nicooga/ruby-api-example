class Api
  resource :users do
    params do
      includes :basic_search
    end

    desc "Retrieves an user", entity: Api::Entities::User

    get do
      users = SEQUEL_DB[:users].all
      { data: users }
    end

    desc "Creates a new user",
      entity: Api::Entities::User,
      params: Api::Entities::User.documentation

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
        present user, with: Api::Entities::User
      end
    end

    route_param(:id) do
      before { authenticate! }

      desc "Updates an user",
        entity: Api::Entities::User,
        params: Api::Entities::User.documentation

      put do
        user = Api::Models::User.find id: params.fetch(:id)
        check_ability_to! :edit, user

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
          present user, with: Api::Entities::User
        end
      end

      desc "Resets the password of an user",
        entity: Api::Entities::User,
        params: Api::Entities::User.documentation

      patch(:reset_password) do
        user = Api::Models::User.find id: params.fetch(:id)
        check_ability_to! :edit, user

        attributes = permit_attributes(%i[new_password new_password_confirmation])
        validation = Api::Validators::Password.new(attributes)

        handling_validation(validation) do
          user = Api::Models::User.find id: params.fetch(:id)
          user.update password: attributes.fetch(:new_password)
          present user, with: Api::Entities::User
        end
      end
    end
  end
end
