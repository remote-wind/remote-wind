require 'rails_helper'

feature "Stations", %{
  the application should have weather stations that are viewable by users
  and  editable by admins
} do

  let(:station) { create(:station, status: :active) }
  let(:observation) { station.observations.create(attributes_for(:observation)) }
  let(:stations) { create_list(:station, 3) }

  let(:admin) { create :admin }
  let(:admin_session) { sign_in! admin }

  scenario "when I view the index page" do
    stations
    visit root_path
    Capybara.find("#left-off-canvas-menu a", text: "Stations").click
    expect(page).to have_selector '.station', count: 3
    expect(page).to have_content stations.first.name
    expect(page).to have_title "Stations | Remote Wind"
  end

  scenario "when I click a station on the index it takes me to the station" do
    stations
    visit stations_path
    click_link stations.first.name
    expect(current_path).to eq station_path(stations.first)
  end

  scenario "when I view a station, it has the correct contents" do
    observation
    visit station_path station
    expect(page).to have_title "#{station.name} | Remote Wind"
    expect(page).to have_selector "table.observations tr:first .speed", text: observation.speed
    expect(page).to have_selector "table.observations tr:first .direction", text: "E (90°)"
  end

  scenario "when I create a new station with valid input" do
    admin_session
    visit stations_path
    click_link "New Station"
    fill_in "Name", with: "Sample Station"
    fill_in "Hardware ID", with: "123456789"
    expect {
      click_button "Create Station"
    }.to change(Station, :count).by(1)

    expect(current_path).to eq station_path("sample-station")
    expect(page).to have_content "Station was successfully created."
    expect(page).to have_selector "h1", text: "Sample Station"
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
    fill_in 'Name', with: 'Station at the End of The World'
    click_button 'Update'
    expect(current_path).to eq station_path(station.slug)
    expect(page).to have_content 'Station at the End of The World'
  end

  context "hidden stations" do
    let!(:deactivated_station) { create(:station, status: :deactivated) }
    let!(:new_station) { create(:station, status: :not_initialized) }

    scenario "when I view index I should not see hidden stations" do
      station =
      station2 = create(:station, status: :not_initialized)
      visit stations_path
      expect(page).to_not have_link deactivated_station.name
      expect(page).to_not have_link new_station.name
    end

    scenario "when I am signed in as an admin and view index I should see hidden stations" do
      admin_session
      visit stations_path
      expect(page).to have_link deactivated_station.name
      expect(page).to have_link new_station.name
    end
  end

  context "given a station with observations" do
    let!(:station) { station = create(:station) }
    before { 3.times { station.observations.create(attributes_for(:observation)) } }

    scenario "when I clear messures" do
      admin_session
      visit station_path station
      click_link "Clear all observations for this station"
      expect(station.observations.count).to eq 0
    end
  end

  scenario "when I change the sampling rate" do
    admin_session
    visit edit_station_path(station)
    fill_in 'Sampling rate', with: 600
    click_button 'Update'
    expect(page).to have_content "00:10:00"
  end

  scenario "when I deactivate a station" do
    admin_session
    visit edit_station_path(station)
    click_button 'Deactivate'
    expect(page).to have_content "deactivated"
  end

  scenario "when I reactivate a station" do
    admin_session
    visit edit_station_path(station)
    click_button 'Deactivate'
    click_link 'Edit'
    click_button 'Activate'
    expect(page).to have_content "active"
  end

  scenario "when I edit the station timezone" do
    admin_session
    visit edit_station_path(station)
    select('Europe/Copenhagen', from: 'Timezone')
    click_button 'Update'
    expect(page).to have_content 'Europe/Copenhagen'
    station.reload
    expect(station.timezone).to eq 'Europe/Copenhagen'
  end
end
