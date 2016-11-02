# @attr id  [Integer]
# @attr name [String]
# @attr hw_id [String]
# @attr latitude [Float]
# @attr longitude [Float]
# @attr balance [Float]  the balance on prepaid phone cards
# @attr timezone [String]
# @attr user_id [Integer]
# @attr created_at [DateTime]
# @attr updated_at [DateTime]
# @attr slug [String]  a URL friendly version of the name. Can be used instead of ID.
# @attr speed_calibration [Float]
# @attr last_observation_received_at [DateTime]
# @attr sampling_rate [Integer]  - how often a station can be expected to send observations
# @attr status [Integer] enum column
# @see https://github.com/norman/friendly_id
# @note When getting a station use the Friendly ID method!
#       Station.friendly.find(params[:id])
#       Since stations can use either the slug or id as param
class Station < ActiveRecord::Base
  # Denotes the general status of a station
  enum status: [:not_initialized, :deactivated, :unresponsive, :active]

  # relations
  belongs_to :user, inverse_of: :stations
  has_many  :observations,
    inverse_of: :station,
    counter_cache: true,
    after_add: ->(s,o){ s.touch if s.persisted? } # touch station so cache key is changed
  has_many :recent_observations, -> { order('created_at ASC').limit(10) }, class_name: 'Observation'
  has_one :current_observation, -> { order('created_at ASC').limit(1) }, class_name: 'Observation'

  # Has scoped roles
  # @see https://github.com/RolifyCommunity/rolify
  resourcify

  # Scopes
  scope :visible, -> { unresponsive.merge(active) }

   # constraints
  validates_uniqueness_of :hw_id
  #validates_presence_of :hw_id
  validates_numericality_of :speed_calibration
  validates_numericality_of :balance, allow_blank: true
  validates_numericality_of :sampling_rate, allow_blank: true, max: 24.hours.to_i

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
  attr_accessor :zone
  attr_accessor :latest_observation

  # Scope that eager loads the latest N number of observations.
  # @note requires Postgres 9.3+
  # @param [Integer] limit - the number of observations to eager load
  # @return [ActiveRecord::Relation]
  def self.with_observations(limit = 1)
    eager_load(:observations).where(
      'observations.id is null or observations.id in (?)',
      Observation.pluck_from_each_station(limit)
    ).order('observations.created_at DESC')
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
    self.observations.any?
  end

  def self.send_low_balance_alerts stations = Station.all()
    stations.each do |station|
      station.check_balance
    end
  end

  # Rake task which periodically tests the status of each station.
  # @param array
  def self.check_all_stations stations = Station.all
    stations.each do |s|
      s.check_status!
    end
  end

  def time_to_local(time)
    Timezone['Europe/Stockholm'].time(time)
  end

  # Checks if a station has been responding regulary.
  # New stations are allowed a certain leeway.
  # @return [Boolean]
  def is_unresponsive?
    # Based on the default sampling_rate this is 24 minutes
    deadline = (sampling_rate * 4.8).seconds.ago
    count = 3
    # Allows new stations leeway
    if created_at > deadline
      count = ((Time.current - created_at) / sampling_rate).floor
    end
    observations.desc
               .since( deadline )
               .count < count
  end

  # Used to check the status of a station when new observations are created or
  # by a scheduled rake task.
  # Will email/notify the station owner.
  # @return [void]
  def check_status!
    if is_unresponsive?
      if active?
        self.unresponsive!
        Services::Notifiers::StationOffline.call(self)
      end
    else
      unless active?
        self.active!
        Services::Notifiers::StationOnline.call(self)
      end
    end
  end

  # Send notifications if station balance is low
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
      eta = (last_observation_received_at - sampling_rate.ago).round
    else
      sampling_rate
    end
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

  def observations_per_day
    1.day / sampling_rate
  end
end
