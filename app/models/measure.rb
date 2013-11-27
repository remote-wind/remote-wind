class Measure < ActiveRecord::Base
  belongs_to :station, dependent: :destroy, inverse_of: :measures

  # constraints
  validates_presence_of :station
  validates :speed, :direction, :max_wind_speed, :min_wind_speed,
            :numericality => { :allow_blank => true }

  def compass_point
    Geocoder::Calculations.compass_point(self.direction)
  end

  # aliases for
  alias_attribute :i, :station_id
  alias_attribute :s, :speed
  alias_attribute :d, :direction
  alias_attribute :max, :max_wind_speed
  alias_attribute :min, :min_wind_speed

  def s= val
    # @todo normalize!
    write_attribute(:speed, val)
  end

  def d= val
    # @todo normalize!
    write_attribute(:direction, val * 10)
  end

  def max= val
    # @todo normalize!
    write_attribute(:max_wind_speed, val)
  end

  def min= val
    # @todo normalize!
    write_attribute(:min_wind_speed, val)
  end
end