#include Geokit::Geocoders
class Station < ActiveRecord::Base
  acts_as_mappable :default_units => :kms,
                     :lat_column_name => :lat,
                     :lng_column_name => :lon

  belongs_to :user
  has_many :measures, :dependent => :destroy
  has_one :current_measure, :class_name => "Measure", :order => 'id desc'
  
  # arduino client has not memory enough to post the station name so it cannot be required!
  validates :hw_id, :presence => true # must have a hw_id
  validates :hw_id, :uniqueness => true # and the hw_id must be unique
  
  def owned_by?(owner)
    user==owner
  end
  
  def calibrate_speed(speed)
    speed/250
  end
  
  def self.send_low_balance_alerts
    stations = Station.find(:all)
    stations.each do |station|
      logger.info "Checking station #{station.name}"
      logger.info "Last measure at #{station.current_measure.created_at}"
      if station.balance/100 < 15 && !station.down
        if !station.user.nil?
          logger.info "Send reminder to owner #{station.user}"
          UserMailer.notify_about_low_balance(station.user, station).deliver
        end
      end
    end
  end
  
  def self.send_down_alerts
    stations = Station.find(:all)
    stations.each do |station|
      logger.info "Checking station #{station.name}"
      logger.info "Last measure at #{station.current_measure.created_at}"
      if station.current_measure.created_at < 15.minutes.ago && !station.down
        station.down = true
        station.save
        if !station.user.nil?
          logger.info "Send reminder to owner #{station.user}"
          UserMailer.notify_about_station_down(station.user, station).deliver
        end
      end
    end
  end
end
