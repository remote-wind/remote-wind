class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    # Use crud alias instead of manage since it can grant invitation access for example.
    alias_action :create, :read, :update, :destroy,
                 :destroy_multiple, :destroy_all, :update_multiple, :update_all,
                 to: :crud

    can :read, User
    can :read, Role
    can :find, Station
    can :read, Station do |s|
      s.show?
    end

    can [:read, :create], Observation
    can :crud, Notification do |note|
      note.user_id == user.id
    end

    # user can manage own profile
    can :crud, User do |u|
      u.id == user.id
    end

    # user can manage own profile
    can :crud, UserAuthentication do |auth|
      auth.user_id == user.id
    end

    if user.has_role? :admin
      can :manage, :all
    end

  end
end
