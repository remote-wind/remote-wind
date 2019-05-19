FactoryBot.define do
  factory :notification do
    user
    event     { :a_sample_key }
    message   { "Hello world!" }
  end
end
