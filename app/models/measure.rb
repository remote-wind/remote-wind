class Measure < ActiveRecord::Base
  belongs_to :station, dependent: :destroy, inverse_of: :measures
  attr_accessor :timezone

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

  default_scope { where("created_at > ?", 12.hours.ago) }

  scope :since, ->(time) { where("created_at > ?", time).order("created_at ASC") }

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

  def time
    unless self.station.timezone.nil?
      self.timezone = Timezone::Zone.new :zone => self.station.timezone
    end
    self.timezone.time self.created_at
  end



end