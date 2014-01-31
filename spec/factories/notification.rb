FactoryGirl.define do
  factory :notification do
    event :a_sample_key
    message "Hello world!"
  end
end