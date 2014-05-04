require 'spec_helper'
describe 'measures/measure' do

  let(:station) { build_stubbed(:station) }
  let(:measure) { build_stubbed(:measure, created_at: Time.new(2000)) }

  before(:each) do
    render partial: 'measures/measure.json.jbuilder',
           locals: {
               station: station,
               measure: measure
           }
  end

  subject { OpenStruct.new(JSON.parse(rendered)) }

  it_should_behave_like "a measure"



end