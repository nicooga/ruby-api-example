require 'ability_list'

class Api
  class Abilities < AbilityList
    def initialize(user)
      can :view, Api::Models::User

      can :edit, Api::Models::User do |check_user|
        next true if user.id == check_user.id
      end
    end
  end
end
