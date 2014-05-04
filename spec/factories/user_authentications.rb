# == Schema Information
#
# Table name: user_authentications
#
#  id                         :integer          not null, primary key
#  user_id                    :integer
#  authentication_provider_id :integer
#  uid                        :string(255)
#  token                      :string(255)
#  token_expires_at           :datetime
#  params                     :text
#  created_at                 :datetime
#  updated_at                 :datetime
#  provider_name              :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl



FactoryGirl.define do

  sequence(:uid) { |n| n }

  factory :user_authentication do
    provider_name "facebook"
    uid
  end
end
