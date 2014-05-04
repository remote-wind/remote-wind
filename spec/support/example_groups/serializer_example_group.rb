# Allows you to use 'it' and 'its' when testing an ActiveModel::Serializer
# Resource (an ActiveModel instance or double) should be defined with let(:resource)
# sets subject to an OpenStruct
# Borrowed from Benedikt Deicke
# http://benediktdeicke.com/2013/01/custom-rspec-example-groups/
module SerializerExampleGroup
  extend ActiveSupport::Concern

  included do
    metadata[:type] = :serializer

    let(:attributes) do
      resource.attributes.with_indifferent_access
    end
    let(:serializer) { described_class.new(resource) }

    subject { OpenStruct.new(serializer.serializable_hash) }
  end

  RSpec.configure do |config|
    config.include self,
      type: :serializer,
      example_group: { :file_path => %r(spec/serializers) }
  end
end