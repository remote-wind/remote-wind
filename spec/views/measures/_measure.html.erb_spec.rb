require 'spec_helper'

describe 'measures/measure' do

  let(:station) { build_stubbed(:station) }
  let(:measure) { build_stubbed(:measure) }

  subject(:row) do
    render partial: 'measures/measure',
           locals: { station: station, measure: measure }
    rendered
  end

  it "has the correct data" do
    expect(row).to have_selector '.measure'
    expect(row).to have_selector '.speed', text: measure.speed
    expect(row).to have_selector '.direction', text: "E (90°)"
  end

end