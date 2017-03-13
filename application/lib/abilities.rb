require 'ability_list'

class Api
  class Abilities < AbilityList
    def initialize(user)
      can :view, Api::Models::User

      can [:edit, :reset_password], Api::Models::User do |check_user|
        next true if user.id == check_user.id
      end
    end
  end
end
