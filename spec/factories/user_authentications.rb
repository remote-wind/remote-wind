# Read about factories at https://github.com/thoughtbot/factory_girl



FactoryGirl.define do

  sequence(:uid) { |n| n }

  factory :user_authentication do
    provider_name "facebook"
    uid
  end
end
