require 'spec_helper'

describe 'measures/measure' do

  let(:station) { build_stubbed(:station) }
  let(:measure) { build_stubbed(:measure, created_at: Time.new(2000) ) }

  subject(:row) do
    render partial: 'measures/measure',
           locals: { station: station, measure: measure }
    rendered
  end

  it "has the correct data" do
    expect(row).to have_selector '.created_at', text: "12/31 23:00"
    expect(row).to have_selector '.speed', text: measure.speed
    expect(row).to have_selector '.speed', text: measure.speed
    expect(row).to have_selector '.direction', text: "E (90°)"
  end

end