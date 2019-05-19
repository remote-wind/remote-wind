require 'rails_helper'

RSpec.feature "Stations" do

  include ObservationsHelper
  include_context "Stations"

  subject { page }

  let(:station) { create(:station, status: :active) }
  let(:observation) { station.observations.create(attributes_for(:observation)) }
  let(:stations) do
    create_list(:station, 3)
  end

  let(:admin) { create :admin }
  let(:admin_session) { sign_in! admin }

  def create_observations(station, count = 5)
    count.times.map do |i|
      Timecop.travel( (i*5).minutes.ago ) do
        station.observations.create(attributes_for(:observation))
      end
    end
  end

  scenario "when I view the index page" do
    stations = one_of_each_status.values
                  .each { |s| create(:observation, station: s) }
    visit root_path
    first("a", text: "Stations").click

    stations.each do |s|
      if s.active? || s.unresponsive?
        o = s.observations.last
        expect(page).to have_link s.name, href: station_path(s)
        expect(page).to have_content speed_min_max(o)
        expect(page).to have_content degrees_and_cardinal(o.direction)
      else
        expect(page).to_not have_link s.name, href: station_path(s)
      end
    end

    expect(page).to have_title "Stations | Remote Wind"
    expect(page).to have_selector '.status', text: 'Ok'
    expect(page).to have_selector '.status', text: 'Unresponsive'
    expect(page).to_not have_selector '.status', text: 'Not in use'
    expect(page).to_not have_selector '.status', text: 'Not initialized'
  end

  context "as an admin" do
    let!(:stations) { one_of_each_status }
    scenario "when I view the stations" do
      admin_session
      visit stations_path
      stations.values.each do |s|
        expect(page).to have_link s.name, href: station_path(s)
      end
    end
  end

  context "as station owner" do
    let(:user){ create(:user) }
    let!(:stations) { one_of_each_status }

    let!(:my_stations) { one_of_each_status }

    before do
      my_stations.values.each {|s| user.add_role(:owner, s) }
    end

    scenario "when I view the stations" do
      sign_in! user
      visit stations_path
      stations.slice(:active, :unresponsive).values.each do |s|
        expect(page).to have_link s.name, href: station_path(s)
      end
      stations.slice(:not_initialized, :deactivated).values.each do |s|
        expect(page).to_not have_link s.name, href: station_path(s)
      end

    end
  end

  scenario "when I view a station, it has the correct contents" do
    observations = create_observations(station)

    visit station_path station
    expect(page).to have_title "#{station.name} | Remote Wind"

    observations.each_with_index do |o, i|
      expect(page).to have_content speed_min_max(o)
      expect(page).to have_content degrees_and_cardinal(o.direction)
      # Checks that observations are in the right order
      expect(page).to have_selector ".observation:eq(#{i+1}) .created_at",
        text: o.created_at_local.strftime("%H:%M")
    end
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

  context "given a station with observations", focus: true do
    let!(:station) { station = create(:station) }
    before { 3.times { station.observations.create(attributes_for(:observation)) } }

    scenario "when I clear the observations" do
      admin_session
      #byebug
      visit station_path station.id
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

  scenario "when I click on the station owner" do
    admin_session
    visit station_path(station)
    click_link(station.user.display_name)
    expect(current_path).to include user_path(station.user)
  end
end
