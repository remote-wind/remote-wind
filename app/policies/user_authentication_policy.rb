class UserAuthenticationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(user: user)
    end
  end

  def show?
    user = record.user
  end

  def create?
    false
  end
  
  def update?
    user = record.user
  end

  def destroy?
    user = record.user
  end
end
