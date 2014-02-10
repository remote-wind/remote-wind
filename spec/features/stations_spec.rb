feature "Stations", %{
  the application should have weather stations that are viewable by users
  and  editable by admins
} do

  let(:station) { create :station }

  let(:stations) do
    [*1..3].map! do |i|
      station = create(:station, :name => "Station #{i+1}")
      station.measures.create attributes_for(:measure)
      station
    end
  end

  let(:admin) {
    create :admin
  }

  let(:admin_session) {
    sign_in! admin
  }

  scenario "when I view the index page" do
    stations
    visit root_path
    Capybara.find("#left-off-canvas-menu a", :text => "Stations").click
    expect(page).to have_selector '.station', count: 3
    expect(page).to have_content stations[0].name
  end

  scenario "when I click on a station" do
    stations
    visit stations_path
    Capybara.find("#left-off-canvas-menu a", :text => stations.first.name).click
    expect(current_path).to eq station_path(stations.first)
  end

  scenario "when viewing a station" do
    visit station_path station
    expect(page).to have_content station.name
  end

  scenario "when i click table" do
    station.measures.create(attributes_for(:measure))
    visit station_path station
    click_link "Table"
    expect(page).to have_selector "table.measures tr:first .speed", text: station.current_measure.speed
    expect(page).to have_selector "table.measures tr:first .direction", text: "E (90°)"
  end

  scenario "table should have station local time" do
    visit station_path station
  end

  describe "creating stations" do

    background do
      admin_session
      visit stations_path
      click_link "New Station"
      fill_in "Name", with: "Sample Station"
      fill_in "Hardware ID", with: "123456789"
    end

    scenario "when I create a new station with valid input" do
      click_button "Create Station"
      expect(current_path).to eq station_path("sample-station")
    end

    scenario "when I create a new station with valid input" do
      click_button "Create Station"
      expect(page).to have_content "Station was successfully created."
    end

    scenario "when I create a new station with valid input" do
      click_button "Create Station"
      expect(page).to have_selector "h1", text: "Sample Station"
    end

  end

  scenario "when I click edit on a station" do
    station
    admin_session
    visit station_path station
    click_link("Edit")
    expect(current_path).to include edit_station_path(station)
  end

  scenario "when I edit a page" do
    admin_session
    visit edit_station_path(station)
    fill_in 'Latitude', with: 999
    click_button 'Update'
    expect(current_path).to eq station_path(station.slug)
  end

  scenario "when I make a station hidden" do
    admin_session
    visit edit_station_path(station)
    uncheck 'Show'
    click_button 'Update'
    sign_out_via_capybara
    visit stations_path
    expect(page).to_not have_selector "a", text: station.name
  end

  scenario "when I edit a station, it should not become hidden" do
    station
    admin_session
    visit edit_station_path(station)
    click_button 'Update'
    sign_out_via_capybara
    visit stations_path
    expect(page).to have_selector "a", text: station.name
  end

  context "given a station with measures" do
    let!(:station) do
      station = create(:station)
      3.times do
        station.measures.create attributes_for(:measure)
      end
      station
    end

    scenario "when i clear messures" do
      admin_session
      visit station_path station
      click_link "Clear all measures for this station"
      expect(Measure.where("station_id = #{station.id}").count).to eq 0
    end
  end

  scenario "when I visit station page map should have correct values" do
    station
    create(:measure, station: station, created_at: 15.minutes.ago)
    create(:measure, station: station, created_at: 10.minutes.ago)
    create(:measure, station: station, created_at: 5.minutes.ago, speed: 10, direction: 180)

    expected = station.current_measure
    visit station_path station
    map_marker_path = '.map-canvas .measure'
    table_path = 'table.measures .measure:first '

    expect(page).to have_selector map_marker_path + "[data-uid='#{expected.id}']"
    expect(page).to have_selector map_marker_path + "[data-speed='#{expected.speed}']"
    expect(page).to have_selector map_marker_path + "[data-direction='#{expected.direction}']"
    expect(page).to have_selector "table.measures .measure[data-uid='#{expected.id}']"
    expect(page).to have_selector table_path + ".direction", text: "S (180°)"
    expect(page).to have_selector table_path + ".speed", text: "10.0 (10.0-55.0)m/s"
  end
end