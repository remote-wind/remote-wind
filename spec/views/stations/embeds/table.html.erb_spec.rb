require 'spec_helper'

describe 'stations/embeds/table', type: :view do

  let(:station) { build_stubbed(:station) }
  let(:observations) {[build_stubbed(:observation)] }

  before(:each) do
    assign(:station, station)
    assign(:observations, observations)
    assign(:embed_options, {})
  end

  subject(:table) do
    render
    rendered
  end

  it "renders observations" do
    expect(table).to have_selector '.observation', exact: observations.size
  end

end