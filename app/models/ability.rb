class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.has_role? :super_admin
      can :manage, :all
    else
      can :manage, User do |u|
        u.id == user.id
      end
    end
  end
end
