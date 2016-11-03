# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryGirl.define do
  factory :user do
    sequence(:nickname) { FFaker::Internet.user_name }
    sequence(:email) { FFaker::Internet.safe_email }
    password 'changeme'
    password_confirmation 'changeme'
    # required if the Devise Confirmable module is used
    confirmed_at Time.now

    factory :admin do
      after(:create) do |admin|
        admin.add_role(:admin)
      end
    end

    factory :unconfirmed_user do
      confirmed_at nil
    end
  end
end
