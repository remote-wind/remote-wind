require 'spec_helper'

describe 'stations/station' do

  let(:station) { build_stubbed(:station, slug: 'foo') }

  before(:each) do
    render partial: 'stations/station',
           locals: { station: station }
  end

  subject(:json) { OpenStruct.new( JSON.parse(response) ) }

  it_behaves_like 'a station'

end