class Station < ActiveRecord::Base

  # relations
  belongs_to :user, inverse_of: :stations
  has_many  :measures, inverse_of: :station, counter_cache: true

            # constraints
  validates_uniqueness_of :hw_id
  validates_presence_of :hw_id

  # slugging
  extend FriendlyId
  friendly_id :name, :use => [:slugged, :history]

  # geolocation
  geocoded_by :name
  reverse_geocoded_by :latitude, :longitude
  class_attribute :zone_class
  self.zone_class ||= Timezone::Zone
  before_save :set_timezone!

  alias_attribute :lat, :latitude
  alias_attribute :lon, :longitude
  alias_attribute :lng, :longitude
  alias_attribute :owner, :user

  def lookup_timezone
    timezone = self.zone_class.new(:latlon => [self.lat, self.lon])
    timezone.active_support_time_zone
  end

  def set_timezone!
    if self.timezone.nil? and !self.latitude.nil? and !self.longitude.nil?
      # Lookup timezone and catch errors due to geonames not answering
      begin
        self.timezone = self.lookup_timezone
      rescue Timezone::Error::Base => e
        logger.warn e.message
      end
    end
  end

  def should_generate_new_friendly_id?
    if !slug?
      name_changed?
    else
      false
    end
  end

  def current_measure
     self.measures.last
  end

  def measures?
    self.measures.present?
  end

  def self.send_low_balance_alerts
    stations = Station.all()
    stations.each do |station|
      logger.info "Checking station #{station.name}"

      if station.measures?
        logger.info "Last measure at #{station.current_measure.created_at}"
      end

      if station.balance < 15 && !station.down
        if !station.user.nil?
          logger.warn "Station low balance alert: #{station.name} only has #{station.balance} kr left! Notifing owner."
          StationMailer.notify_about_low_balance(station.user,station)
        end
      end
    end
  end

  def self.send_down_alerts
    stations = Station.all()
    stations.each do |station|
      logger.info "Checking station #{station.name}"
      if !station.measures?
        station.down = true
        station.save
        logger.warn "Station down alert: #{station.name} is down"
        return
      else
        if station.current_measure.created_at < 15.minutes.ago && !station.down
          station.down = true
          station.save
          logger.warn "Station down alert: #{station.name} is down"
          if !station.user.nil?
            StationMailer.notify_about_station_down(station.user, station)
          end
        end
      end
    end
  end

end
