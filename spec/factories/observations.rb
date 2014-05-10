# == Schema Information
#
# Table name: observations
#
#  id                :integer          not null, primary key
#  station_id        :integer
#  speed             :float
#  direction         :float
#  max_wind_speed    :float
#  min_wind_speed    :float
#  temperature       :float
#  created_at        :datetime
#  updated_at        :datetime
#  speed_calibration :float
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :observation do
    station_id 1
    speed 30
    direction 90
    max_wind_speed 55
    min_wind_speed 10
    temperature 1.5
  end
end
