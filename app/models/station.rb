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
  has_many  :observations,
    inverse_of: :station,
    counter_cache: true,
    after_add: ->(s,o){ s.touch if s.persisted? } # touch station so cache key is changed
  has_many :recent_observations, -> { order('created_at ASC').limit(10) }, class_name: 'Observation'
  has_one :current_observation, -> { order('created_at ASC').limit(1) }, class_name: 'Observation'

   # constraints
  validates_uniqueness_of :hw_id
  #validates_presence_of :hw_id
  validates_numericality_of :speed_calibration
  validates_numericality_of :balance, allow_blank: true

  # geolocation
  geocoded_by :name
  reverse_geocoded_by :latitude, :longitude

  #callbacks
  before_validation :set_timezone!
  after_initialize :set_timezone!
  after_save :calibrate_observations!, if: :speed_calibration_changed?

  # Attribute aliases
  alias_attribute :lat, :latitude
  alias_attribute :lon, :longitude
  alias_attribute :lng, :longitude
  alias_attribute :owner, :user
  attr_accessor :zone
  attr_accessor :latest_observation

  # Scopes
  scope :visible, -> { where( show: true ) }

  # Scope that eager loads the latest N number of observations.
  # @note requires Postgres 9.3+
  # @param [Integer] limit - the number of observations to eager load
  # @return [ActiveRecord::Relation]
  def self.with_observations(limit = 1)
    eager_load(:observations).where(
      observations: { id: Observation.pluck_from_each_station(limit) }
    )
  end

  # Setup default values for new records
  after_initialize do
    if self.new_record?
      self.speed_calibration = 1
    end
  end

  # Updates the "cached" speed_calibration value on the observations table
  def calibrate_observations!
    self.observations.update_all(speed_calibration: self.speed_calibration)
  end

  # Lookup timezone via lat/lng
  def lookup_timezone
    self.zone = Timezone::Zone.new(latlon: [self.lat, self.lon])
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
  friendly_id :name, use: [:slugged, :history]

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
    if self.observations.loaded?
      self.observations.length > 0
    else
      self.observations.present?
    end
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
      observations.desc
                 .since(24.minutes.ago)
                 .count < 3
  end

  def check_status!
    if should_be_offline?
      unless offline?
        update_attribute('offline', true)
        Services::Notifiers::StationOffline.call(self)
      end
    else
      if offline?
        update_attribute('offline', false)
        Services::Notifiers::StationOnline.call(self)
      end
    end
  end

  # Send notifications if station balance is low
  # @return boolean true for ok balance, false if balance is low
  def check_balance
    if low_balance?
      Services::Notifiers::LowBalance.call(self)
    end
    !low_balance?
  end

  def low_balance?
    balance < 15
  end

  def last_observation_received_at
    observations.last.try(:created_at)
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

  # Custom getter to get the rate as a Duration instead of an integer
  # @see http://api.rubyonrails.org/classes/ActiveSupport/Duration.html
  # @return [ActiveSupport::Duration | nil]
  def sampling_rate(unit: :seconds)
    if self[:sampling_rate].nil? || self[:sampling_rate].is_a?(ActiveSupport::Duration)
      self[:sampling_rate]
    else
      self[:sampling_rate].seconds
    end
  end
end
