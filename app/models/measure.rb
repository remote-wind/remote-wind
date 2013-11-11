class Measure < ActiveRecord::Base
  belongs_to :station, dependent: :destroy
  # constraints
  validates_presence_of :station
  validates :speed, :direction, :max_wind_speed, :min_wind_speed, :temperature,
            :numericality => { :allow_blank => true }

end