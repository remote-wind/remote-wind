# Allows you to use 'it' and 'its' when testing an ActiveModel::Serializer
# Resource (an ActiveModel instance or double) should be defined with let(:resource)
# sets subject to an OpenStruct
# Borrowed from Benedikt Deicke
# http://benediktdeicke.com/2013/01/custom-rspec-example-groups/

require 'factory_bot'
require 'ostruct'

module SerializerExampleGroup

  extend ActiveSupport::Concern

  included do
    let(:resource_name) do
      described_class.name.demodulize.underscore[0..-12].to_sym
    end
    let(:resource) { build_stubbed resource_name }
    let(:serializer) { described_class.new(resource) }
    subject { OpenStruct.new(serializer.attributes) }
  end

  RSpec.configure do |config|
    config.include self,
      type: :serializer,
      file_path: %r(spec/serializers)
  end
end
