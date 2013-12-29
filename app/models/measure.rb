class Measure < ActiveRecord::Base
  belongs_to :station, dependent: :destroy, inverse_of: :measures
  attr_accessor :timezone

  # constraints
  validates_presence_of :station
  validates :speed, :direction, :max_wind_speed, :min_wind_speed,
            :numericality => { :allow_blank => true }
  validate :measure_cannot_be_calibrated

  # degrees to cardinal
  def compass_point
    Geocoder::Calculations.compass_point(self.direction)
  end

  alias_attribute :i, :station_id
  alias_attribute :s, :speed
  alias_attribute :d, :direction
  alias_attribute :max, :max_wind_speed
  alias_attribute :min, :min_wind_speed

  attr_accessor :calibrated
  after_save :calibrate!

  # Scopes
  default_scope { order("created_at DESC").limit(144) }
  scope :since, ->(time) { where("created_at > ?", time) }

  # when writing from the ardiuno params short form
  def s= val
    write_attribute(:speed, val.to_f / 100)
  end

  # when writing from the ardiuno params short form
  def d= val
    write_attribute(:direction, (val.to_f / 10).round(0))
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


  def calibrated?
    self.calibrated == true
  end

  def calibrate!
    unless self.calibrated
      unless self.station.speed_calibration.nil?
        self.speed            = (self.speed * self.station.speed_calibration).round(1)
        self.min_wind_speed   = (self.min_wind_speed * self.station.speed_calibration).round(1)
        self.max_wind_speed   = (self.max_wind_speed * self.station.speed_calibration).round(1)
        self.calibrated = true
      end
    end
  end

  def measure_cannot_be_calibrated
    if self.calibrated
      errors.add(:speed_calbration, "Calibrated measures cannot be saved!")
    end
  end

end