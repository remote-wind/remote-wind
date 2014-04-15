require 'spec_helper'

describe "stations/_map" do

  let(:station) { build_stubbed(:station) }
  let(:measure) { build_stubbed(:measure, station: station) }

  let!(:page) do
    station.latest_measure = measure
    stub_user_for_view_test
    render "stations/map", stations: [station]
    rendered  
  end

  it "has the correct contents" do
    expect(page).to have_selector "#map_canvas .marker .title", text: station.name
    expect(page).to have_selector "#map_canvas .marker[data-lat='#{station.lat}']"
    expect(page).to have_selector "#map_canvas .marker[data-lon='#{station.lon}']"
    expect(page).to have_selector(".measure[data-min-speed='#{measure.min}']")
    expect(page).to have_selector(".measure[data-max-speed='#{measure.max}']")
    expect(page).to have_selector(".measure[data-direction='#{measure.direction}']")
  end

end

