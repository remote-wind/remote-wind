require 'rails_helper'

describe "stations/_map", type: :view do

  let(:station) { build_stubbed(:station, lat: 10, lon: 15) }
  let(:observation) { build_stubbed(:observation, station: station) }

  let!(:page) do
    station.latest_observation = observation
    stub_user_for_view_test
    render "stations/map", station: station
    rendered  
  end

  it "has the correct contents" do
    expect(page).to have_selector "#map_canvas"
    expect(page).to have_selector ".controls"
    expect(page).to match 'data-lat="10"'
    expect(page).to match 'data-lng="15"'
  end

end

