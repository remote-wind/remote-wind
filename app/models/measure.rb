class Measure < ActiveRecord::Base
  belongs_to :station, dependent: :destroy
  # constraints
  validates_presence_of :station
  validates :speed, :direction, :max_wind_speed, :min_wind_speed,
            :numericality => { :allow_blank => true }

  @@dict = {
      :speed => :s,
      :direction => :d,
      :station_id => :i,
      :max_wind_speed => :max,
      :min_wind_speed => :min,
      :temperature => :t
  }

  def self.params_to_long_form params
    mappings = @@dict.invert.with_indifferent_access
    Hash[params.map {|k, v| [mappings[k] || k, v] }]
  end

  def self.params_to_short_form params
    mappings = @@dict.with_indifferent_access
    Hash[params.map {|k, v| [mappings[k] || k, v] }]
  end

end