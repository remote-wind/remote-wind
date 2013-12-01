# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  sequence(:hw_id) { |n| "hw_id_#{n}" }
  sequence(:name) { |n| "Station #{n}" }

  factory :station do
    name
    hw_id
    latitude 51.478885
    longitude -0.010635
    balance 1
    down nil
    user nil
    speed_calibration 0
  end
end
