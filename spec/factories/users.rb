# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryGirl.define do

  factory :user do
    nickname 'j_random_user'
    email 'example@example.com'
    password 'changeme'
    password_confirmation 'changeme'
    # required if the Devise Confirmable module is used
    confirmed_at Time.now
  end

  factory :unconfirmed_user, class: User do
    nickname 'j_random_user'
    email 'example@example.com'
    password 'changeme'
    password_confirmation 'changeme'
  end

  factory :admin, class: User  do
    nickname 'the_boss'
    email "admin@example.com"
    password "abc123123"
    password_confirmation { "abc123123" }
    after(:create) do |admin|
      admin.add_role(:admin)
    end
    confirmed_at Time.now
  end

end

