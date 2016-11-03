class StationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if is_admin?
        scope.all
      else
        scope.where(
          "stations.status IN (2,3) OR stations.id IN (?)",
          Station.with_role(:owner, user).pluck(:id)
        )
      end
    end
  end

  def show?
    is_admin? || is_owner?
  end

  def create?
    is_admin?
  end

  def update?
    is_admin? || is_owner?
  end

  def destroy?
    is_admin? || is_owner?
  end

  # This is one of those quirky Ardiuno station things...
  def api_firmware_version?
    true
  end

  # This is one of those quirky Ardiuno station things...
  def update_balance?
    true
  end

  def find?
    true
  end

  def search?
    true
  end

  def permitted_attributes
    [
      :name, :hw_id, :latitude, :longitude, :user_id, :slug, :speed_calibration,
      :description, :sampling_rate, :status, :timezone
    ]
  end

  def is_owner?
    user.has_role?(:owner, record)
  end
end
