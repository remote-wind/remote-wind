# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :measure do
    station_id 1
    speed 30
    direction 90
    max_wind_speed 55
    min_wind_speed 10
    temperature 1.5
  end
end
