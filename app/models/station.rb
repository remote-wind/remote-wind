class Station < ActiveRecord::Base
  extend FriendlyId
  belongs_to :user
  has_many  :measures
  validates_uniqueness_of :hw_id
  validates_presence_of :hw_id
  class_attribute :zone_class
  self.zone_class ||= Timezone::Zone
  friendly_id :name, :use => [:slugged, :history]
  before_save :evaluate_slug
  before_save :set_timezone!

  def lat
    read_attribute(:latitude)
  end

  def lat=(lat)
    write_attribute(:latitude, lat)
  end

  def lon
    read_attribute(:longitude)
  end

  def lon=(lon)
    write_attribute(:longitude, lon)
  end

  def find_timezone
    timezone = self.zone_class.new(:latlon => [self.lat, self.lon])
    timezone.active_support_time_zone
  end

  def set_timezone!
    if self.timezone.nil? and !self.latitude.nil? and !self.longitude.nil?
      begin
        self.timezone = self.find_timezone
      rescue Timezone::Error::NilZone => e
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

  def evaluate_slug

  end

end
