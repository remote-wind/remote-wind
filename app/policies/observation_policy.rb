class ObservationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  delegate :update?, :destroy?, to: :station_policy
  # Used to proxy permissions to the station
  def station_policy
    StationPolicy.new(user, record.station)
  end

  def show?
    true
  end

  # Since the stations do not currently authenticate this must be true
  def create?
    true
  end

  def permitted_attributes
    [:direction, :speed, :min_wind_speed, :max_wind_speed]
  end
end
