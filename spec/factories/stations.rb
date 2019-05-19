# Read about factories at https://github.com/thoughtbot/factory_bot
FactoryBot.define do
  factory :station do
    sequence(:hw_id) { |n| "hw_id_#{n}" }
    sequence(:name) { |n| "Station #{n}" }
    latitude { 51.478885 }
    longitude { -0.010635 }
    balance { 1 }
    status { :active }
    user
    speed_calibration { 1 }
    updated_at { Time.now }
  end
end
