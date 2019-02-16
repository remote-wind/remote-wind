class LatestObservation < ActiveRecord::Base
  # this is more or less a direct copy of Observation class to just store one
  # reading per stations, the latest. To speed up DB queries. Can certainly be
  # made in a much better way

  belongs_to :station, dependent: :destroy
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
  after_save :calibrate!
  after_save :update_stations_updated_at

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
      self.speed            = (self.speed * c).round(1)
      self.min_wind_speed   = (self.min_wind_speed * c).round(1)
      self.max_wind_speed   = (self.max_wind_speed * c).round(1)
      self.calibrated = true
    end
  end

  def update_stations_updated_at
    self.station.touch
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

  # Plucks the IDs of the N latest observations from each station
  # @note requires Postgres 9.3
  # @see https://github.com/remote-wind/remote-wind/issues/112
  # @param [Integer] limit
  # @return [Array]
  def self.pluck_from_each_station(limit = 1)
    ActiveRecord::Base.connection.execute(%Q{
      SELECT o.id
      FROM   stations s
      JOIN   LATERAL (
         SELECT id, created_at
         FROM   observations
         WHERE  station_id = s.id  -- lateral reference
         ORDER  BY created_at DESC
         LIMIT  #{limit}
         ) o ON TRUE
      ORDER  BY s.id, o.created_at DESC;
    }).field_values('id')
  end
end
