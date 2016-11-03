class NotificationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def show?
    user = record.user
  end

  def create?
    false
  end

  def destroy?
    user = record.user
  end

  def update?
    user = record.user
  end
end
