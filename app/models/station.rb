class Station < ActiveRecord::Base
  belongs_to :user
  validates_uniqueness_of :hw_id
  validates_presence_of :hw_id
  before_create :set_timezone!
  geocoded_by :name
  has_many :measures

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
    timezone = Timezone::Zone.new :latlon => [self.lat, self.lon]
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

end
