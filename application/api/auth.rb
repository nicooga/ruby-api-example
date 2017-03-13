# I would rather use different module and mount that into the api
# than abusing the monkey patching, but let's not change the coding pattern
class Api
  namespace :auth do
    post do
      data = permit_attributes(%i[user_id password])
      user = Api::Models::User.find id: data.fetch(:user_id)

      if user.password == data.fetch(:password)
        { token: generate_token(user) }
      else
        raise Api::AuthenticationError.new('Password does not match')
      end
    end
  end
end
