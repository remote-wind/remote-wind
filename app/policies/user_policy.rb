class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def show?
    true
  end

  def update?
    is_admin? || self?
  end

  def destroy?
    !self? && is_admin?
  end

  def self?
    user == record
  end
end
