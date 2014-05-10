feature "Station calibration" do

  let!(:station) { create(:station) }
  let!(:observation) { create(:observation, station: station, min_wind_speed: 5, speed: 10, max_wind_speed: 20) }

  scenario "when i edit a station speed calibration" do
    sign_in! create(:admin)
    visit edit_station_path(station)
    fill_in "Speed Calibration", with: 2
    click_button "Update"
    expect(page).to have_selector ".speed", text: "20.0 (10.0-40.0)m/s"
  end
end