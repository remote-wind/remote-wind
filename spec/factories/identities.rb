# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :identity do
    user ""
    provider "MyString"
    uid "MyString"
  end
end
