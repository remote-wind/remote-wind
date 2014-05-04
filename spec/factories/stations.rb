# == Schema Information
#
# Table name: stations
#
#  id                       :integer          not null, primary key
#  name                     :string(255)
#  hw_id                    :string(255)
#  latitude                 :float
#  longitude                :float
#  balance                  :float
#  down                     :boolean
#  timezone                 :string(255)
#  user_id                  :integer
#  created_at               :datetime
#  updated_at               :datetime
#  slug                     :string(255)
#  show                     :boolean          default(TRUE)
#  speed_calibration        :float            default(1.0)
#  last_measure_received_at :datetime
#

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
    speed_calibration 1
  end
end
