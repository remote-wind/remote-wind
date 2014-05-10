feature "Stations", %{
  the application should have weather stations that are viewable by users
  and  editable by admins
} do

  let(:station) { create :station }

  let(:stations) do
    [*1..3].map! do |i|
      station = create(:station, :name => "Station #{i+1}")
      station.observations.create attributes_for(:observation)
      station
    end
  end

  let(:admin) { create :admin }
  let(:admin_session) { sign_in! admin }

  scenario "when I view the index page" do
    stations
    visit root_path
    Capybara.find("#left-off-canvas-menu a", :text => "Stations").click
    expect(page).to have_selector '.station', count: 3
    expect(page).to have_content stations.first.name
    expect(page).to have_title "Stations | Remote Wind"
  end

  scenario "when I click on a station" do
    stations
    visit stations_path
    click_link stations.first.name
    expect(current_path).to eq station_path(stations.first)
  end

  scenario "when viewing a station" do
    visit station_path station
    expect(page).to have_title "#{station.name} | Remote Wind"
  end

  scenario "when i click table" do
    station.observations.create(attributes_for(:observation))
    visit station_path station
    click_link "Table"
    expect(page).to have_selector "table.observations tr:first .speed", text: station.current_observation.speed
    expect(page).to have_selector "table.observations tr:first .direction", text: "E (90°)"
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
      expect(page).to have_content "Station was successfully created."
      expect(page).to have_selector "h1", text: "Sample Station"
    end

  end

  scenario "when I click edit on a station" do
    station
    admin_session
    visit station_path station
    click_link("Edit")
    expect(current_path).to include edit_station_path(station)
    expect(page).to have_title "Editing #{station.name} | Remote Wind"
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

  context "given a station with observations" do
    let!(:station) do
      station = create(:station)
      3.times do
        station.observations.create attributes_for(:observation)
      end
      station
    end

    scenario "when i clear messures" do
      admin_session
      visit station_path station
      click_link "Clear all observations for this station"
      expect(station.observations.count).to eq 0
    end
  end

end