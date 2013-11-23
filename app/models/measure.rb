class Measure < ActiveRecord::Base
  belongs_to :station, dependent: :destroy
  # constraints
  validates_presence_of :station
  validates :speed, :direction, :max_wind_speed, :min_wind_speed,
            :numericality => { :allow_blank => true }

  def compass_point
    Geocoder::Calculations.compass_point(self.direction)
  end



end