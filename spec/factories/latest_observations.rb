FactoryGirl.define do
  factory :latest_observation do
    station_id 1
    speed 30
    direction 90
    max_wind_speed 55
    min_wind_speed 10
    temperature 1.5
  end
end
