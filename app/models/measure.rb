class Measure < ActiveRecord::Base
  belongs_to :station
  attr_accessor :time_diff

  # must have at least speed, direction and belong to a station
  validates :speed, :direction, :station_id, :presence => true 
  # the station object must exist, cannot submit values from a none existing station
  validates :station, :presence => true
  # verify that if included submitted values are integers
  validates :speed, :direction, :max_wind_speed, :min_wind_speed, :temperature,
            :numericality => { :only_integer => true, :allow_blank => true } 
  
end
