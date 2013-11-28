class Measure < ActiveRecord::Base
  belongs_to :station, dependent: :destroy, inverse_of: :measures

  # constraints
  validates_presence_of :station
  validates :speed, :direction, :max_wind_speed, :min_wind_speed,
            :numericality => { :allow_blank => true }

  # degrees to cardinal
  def compass_point
    Geocoder::Calculations.compass_point(self.direction)
  end

  alias_attribute :i, :station_id
  alias_attribute :s, :speed
  alias_attribute :d, :direction
  alias_attribute :max, :max_wind_speed
  alias_attribute :min, :min_wind_speed

  # when writing from the ardiuno params short form
  def s= val

    write_attribute(:speed, val.to_f / 100)
  end

  # when writing from the ardiuno params short form
  def d= val
    write_attribute(:direction, val.to_f / 10)
  end

  # when writing from the ardiuno params short form
  def max= val
    write_attribute(:max_wind_speed, val.to_f / 100)
  end

  # when writing from the ardiuno params short form
  def min= val
    write_attribute(:min_wind_speed, val.to_f / 100)
  end

  def b=
    write_attribute(:min_wind_speed, val.to_f / 100)
  end

end