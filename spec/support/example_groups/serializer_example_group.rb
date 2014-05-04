# Allows you to use 'it' and 'its' when testing an ActiveModel::Serializer
# Attributes should be defined with let(:attibutes)
# sets subject to an OpenStruct
# Thanks to Benedikt Deicke
# http://benediktdeicke.com/2013/01/custom-rspec-example-groups/


module SerializerExampleGroup
  extend ActiveSupport::Concern

  included do
    metadata[:type] = :serializer

    let(:attributes) do
      {}
    end

    let(:resource_name) do
      described_class.name.underscore[0..-12].to_sym
    end

    let(:resource) do
      double(resource_name, attributes).tap do |double|
        double.stub(:read_attribute_for_serialization) { |name| attributes[name] }
      end
    end

    let(:serializer) { described_class.new(resource) }

    subject { OpenStruct.new(serializer.serializable_hash) }
  end

  RSpec.configure do |config|
    config.include self,
      :type => :serializer,
      :example_group => { :file_path => %r(spec/serializers) }
  end
end