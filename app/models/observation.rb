# Respresents a series of measurements taken by a weather station.
# Take extreme care when querying this table as it contrains a lot of rows!
class Observation < ActiveRecord::Base

  belongs_to :station,
    dependent: :destroy,
    inverse_of: :observations,
    required: true
  attr_accessor :timezone

  # constraints
  validates_presence_of :station
  validates :speed, :direction, :max_wind_speed, :min_wind_speed, :speed_calibration,
            numericality: { allow_blank: true }
  validate :observation_cannot_be_calibrated

  alias_attribute :max, :max_wind_speed
  alias_attribute :min, :min_wind_speed

  attr_accessor :calibrated
  after_validation :set_calibration_value!
  after_find :calibrate!

  # Scopes
  # default_scope { order("created_at DESC").limit(144) }
  scope :since, ->(time) { where("created_at > ?", time) }
  scope :desc, -> { order('created_at DESC') }

  def calibrated?
    self.calibrated == true
  end

  def calibrate!
    unless self.calibrated || self.speed_calibration.nil?
      c = self.speed_calibration
      self.speed            = self.speed.nil? ? nil : (self.speed * c).round(1)
      self.min_wind_speed   = self.min_wind_speed.nil? ? nil : (self.min_wind_speed * c).round(1)
      self.max_wind_speed   = self.max_wind_speed.nil? ? nil : (self.max_wind_speed * c).round(1)
      self.calibrated = true
    end
  end

  def observation_cannot_be_calibrated
    if self.calibrated
      errors.add(:speed_calibration, "Calibrated observations cannot be saved!")
    end
  end

  def set_calibration_value!
    if self.station.present?
      self.speed_calibration = station.speed_calibration
    end
  end

  def created_at_local
    station.time_to_local(created_at)
  end

  # degrees to cardinal
  def compass_point
    self.direction.nil? ? nil : Geocoder::Calculations.compass_point(self.direction)
  end
  alias_method :cardinal, :compass_point
end
