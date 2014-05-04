require 'spec_helper'
describe 'measures/index.json.jbuilder' do

  let(:station) { build_stubbed(:station) }
  let(:measure) { build_stubbed(:measure, created_at: Time.new(2000)) }

  before(:each) do
    render template: 'measures/index.json.jbuilder',
           locals: {
               station: station,
               measures: [measure]
           }
  end

  subject { OpenStruct.new(JSON.parse(rendered).first) }

  #it_should_behave_like "a measure"



end