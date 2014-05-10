# == Schema Information
#
# Table name: observations
#
#  id                :integer          not null, primary key
#  station_id        :integer
#  speed             :float
#  direction         :float
#  max_wind_speed    :float
#  min_wind_speed    :float
#  temperature       :float
#  created_at        :datetime
#  updated_at        :datetime
#  speed_calibration :float
#

class Observation < ActiveRecord::Base

  belongs_to :station, dependent: :destroy, inverse_of: :observations
  attr_accessor :timezone

  # constraints
  validates_presence_of :station
  validates :speed, :direction, :max_wind_speed, :min_wind_speed, :speed_calibration,
            :numericality => { :allow_blank => true }
  validate :observation_cannot_be_calibrated

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
  after_validation :set_calibration_value!
  after_find :calibrate!
  after_save :calibrate!
  after_save :update_station

  # Scopes
  #default_scope { order("created_at DESC").limit(144) }
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
      unless self.speed_calibration.nil?
        self.speed            = (self.speed * self.speed_calibration).round(1)
        self.min_wind_speed   = (self.min_wind_speed * self.speed_calibration).round(1)
        self.max_wind_speed   = (self.max_wind_speed * self.speed_calibration).round(1)
        self.calibrated = true
      end
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

  # Update station when saving observation
  def update_station
    unless station.nil?
      station.update_attribute(:last_observation_received_at, created_at)
    end
  end

  def created_at_local
    station.time_to_local(created_at)
  end

end
