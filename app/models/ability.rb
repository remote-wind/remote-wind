class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.has_role? :admin
      can :manage, :all
    else
      # user can see own profile
      can :show, User do |u|
        u.id == user.id
      end
      can :read, Station do

      end
    end
  end
end
