# == Schema Information
#
# Table name: stations
#
#  id                           :integer          not null, primary key
#  name                         :string(255)
#  hw_id                        :string(255)
#  latitude                     :float
#  longitude                    :float
#  balance                      :float
#  offline                      :boolean
#  timezone                     :string(255)
#  user_id                      :integer
#  created_at                   :datetime
#  updated_at                   :datetime
#  slug                         :string(255)
#  show                         :boolean          default(TRUE)
#  speed_calibration            :float            default(1.0)
#  last_observation_received_at :datetime
#

# NB! when getting a station use the Friendly ID method Station.friendly.find(params[:id])
# Stations can use either slug or id as param
class Station < ActiveRecord::Base

  # relations
  belongs_to :user, inverse_of: :stations
  has_many  :observations, inverse_of: :station, counter_cache: true
  has_many :recent_observations, -> { order('created_at ASC').limit(10) }, class_name: 'Observation'
  has_one :current_observation, -> { order('created_at ASC').limit(1) }, class_name: 'Observation'

   # constraints
  validates_uniqueness_of :hw_id
  validates_presence_of :hw_id
  validates_numericality_of :speed_calibration
  validates_numericality_of :balance, allow_blank: true

  # geolocation
  geocoded_by :name
  reverse_geocoded_by :latitude, :longitude

  #callbacks
  before_validation :set_timezone!
  after_initialize :set_timezone!

  # Attribute aliases
  alias_attribute :lat, :latitude
  alias_attribute :lon, :longitude
  alias_attribute :lng, :longitude
  alias_attribute :owner, :user
  attr_accessor :zone
  attr_accessor :latest_observation

  # Scopes
  scope :visible, -> { where( show: true ) }

  # Eager load the latest observation.
  scope :with_latest_observation, -> do
    eager_load(:observations).where(observations: { id: Observation.pluck_one_from_each_station } )
  end

  # Eager load the latest N number of observations.
  # @note requires Postgres 9.3+
  # @param [Integer] limit - the number of observations to eager load
  scope :with_observations, ->(limit = 1) do
    eager_load(:observations).where(observations: { id: Observation.pluck_from_each_station(limit) })
  end

  # callbacks
  after_save -> do
    self.observations.update_all(speed_calibration: self.speed_calibration)
  end, if: lambda { |station| station.speed_calibration_changed? }

  # Setup default values for new records
  after_initialize do
    if self.new_record?
      self.speed_calibration = 1
    end
  end

  # Lookup timezone via lat/lng
  def lookup_timezone
    self.zone = Timezone::Zone.new(:latlon => [self.lat, self.lon])
    self.zone.zone
  end

  # Lookup and set timezone
  # Also catches any errors caused by Timezone and logs them
  def set_timezone!
    if self.timezone.nil? and !self.latitude.nil? and !self.longitude.nil?
      # Lookup timezone and catch errors due to geonames not answering
      begin
        self.timezone = self.lookup_timezone
      rescue Timezone::Error::Base => e
        logger.warn e.message
      end
    elsif self.timezone and self.zone.nil?
      self.zone = Timezone::Zone.new( zone: self.timezone )
    end
  end

  # Use FriendlyId to create easily "pretty urls"
  extend FriendlyId
  friendly_id :name, :use => [:slugged, :history]

  # Generate a slug from name if none is given when creating station
  def should_generate_new_friendly_id?
    if !slug?
      name_changed?
    else
      false
    end
  end

  def current_observation
    latest_observation.presence || observations.last
  end

  def observations?
    self.observations.present?
  end

  def self.send_low_balance_alerts stations = Station.all()
    stations.each do |station|
      station.check_balance
    end
  end

  # Rake task which periodically tests the status of each station.
  # @param stations array
  def self.check_all_stations stations = Station.all
    stations.each do |s|
      s.check_status!
    end
  end

  def time_to_local time
    self.zone.nil? ? time : zone.time(time)
  end

  # do heuristics if station is down
  def should_be_offline?
      Observation.where({station_id: id}).since(24.minutes.ago).order(created_at: :desc).count  < 3
  end

  def check_status!
    if should_be_offline?
      unless offline?
        update_attribute('offline', true)
        notify_offline
      end
    else
      if offline?
        update_attribute('offline', false)
        notify_online
      end
    end
  end

  # Log and send notifications that station is down
  def notify_offline

    logger.warn "Station alert: #{name} is now down"
    # Allows tests without user
    if user.present?
      StationMailer.offline(self)

      # create UI notification.
      Notification.create(
          user: self.user,
          level: :warn,
          message: "#{name} is down.",
          event: "station_down"
      )
    end
  end

  # Log and send notifications that station is up
  def notify_online
    logger.info "Station alert: #{name} is now up"
    # Allows tests without user
    if user.present?
      StationMailer.online(self)
      Notification.create(
          user: self.user,
          level: :info,
          message: "#{name} is up.",
          event: "station_up"
      )
    end
  end

  # Send notifications if station balance is low
  # @return boolean true for ok balance, false if balance is low
  def check_balance
    if balance < 15
      Rails.logger.info "#{name} has a low balance, only #{balance} kr left."
      message = "#{name} has a low balance, only #{balance} kr left."
      # Check if there have been notifications of this event
      notified = Notification
        .where(message: message)
        .where("created_at >= ?", 12.hours.ago)
        .count > 0
      if user.presence && !notified
        StationMailer.low_balance(self)
      end
      Notification.create(
          user: self.user,
          level: :info,
          message: message,
          event: "station_low_balance"
      )
      false
    else
      true
    end
  end

  def created_at_local
    time_to_local created_at if created_at.present?
  end

  def updated_at_local
    time_to_local updated_at if updated_at.present?
  end

  def last_observation_received_at_local
    time_to_local updated_at if last_observation_received_at.present?
  end

  def next_observation_expected_in
    if last_observation_received_at
      eta = last_observation_received_at.minus_with_coercion(5.minutes.ago).round()
      return eta.seconds if eta > 0
    end
    5.minutes
  end

  # Does a select query to fetch observations and manually sets up active record association to avoid n+1 query
  # and memory issues when Rails tries to eager load the association without a limit.
  # @see http://mrbrdo.wordpress.com/2013/09/25/manually-preloading-associations-in-rails-using-custom-scopessql/
  # @param [Integer] limit
  # @param [ActiveRecord::Relation] query
  # @return [ActiveRecord::Associations::CollectionProxy]
  def load_observations!(limit = 1, query: Observation.desc)
    observations = query.merge(Observation.where(station: self).limit(limit))
    association = self.association(:observations)
    association.loaded!
    association.target.concat(observations)
    observations.each { |observation| association.set_inverse_instance(observation) }
    self.observations
  end
end
