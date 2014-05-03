require 'spec_helper'

describe 'stations/embeds/table' do

  let(:station) { build_stubbed(:station) }
  let(:measures) {[build_stubbed(:measure)] }

  before(:each) do
    assign(:station, station)
    assign(:measures, measures)
    assign(:embed_options, {})
  end

  subject(:table) do
    render
    rendered
  end

  it "renders measures" do
    expect(table).to have_selector '.measure', exact: measures.size
  end

end