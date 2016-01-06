# == Schema Information
#
# Table name: stations
#
#  id                           :integer          not null, primary key
#  name                         :string(255)
#  hw_id                        :string(255)
#  latitude                     :float
#  longitude                    :float
#  balance                      :float
#  offline                      :boolean
#  timezone                     :string(255)
#  user_id                      :integer
#  created_at                   :datetime
#  updated_at                   :datetime
#  slug                         :string(255)
#  show                         :boolean          default(TRUE)
#  speed_calibration            :float            default(1.0)
#  last_observation_received_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :station do
    sequence(:hw_id) { |n| "hw_id_#{n}" }
    sequence(:name) { |n| "Station #{n}" }
    latitude 51.478885
    longitude -0.010635
    show true
    balance 1
    offline nil
    user
    speed_calibration 1
  end
end
