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
      can :read, Station do |s|
        s.show?
      end
      can :read, Observation do |m|
        m.show?
      end
      can :manage, Notification do |n|
        user.has_role? :admin || n.user_id == user.id
      end
    end
  end
end
