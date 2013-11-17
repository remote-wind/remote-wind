feature "Stations", %{
  the application should have weather stations that are viewable by users
  and  editable by admins
} do

  let!(:stations) {
    stations = []
    3.times do |i|
      stations << create(:station, :name => "Station #{i+1}")
    end
    stations
  }

  let(:admin) {
    create :admin
  }

  let(:admin_session) {
    sign_in! admin
  }

  scenario "when I view the index page" do
    visit root_path
    Capybara.find("header a", :text => "Stations").click
    expect(page).to have_selector '.station', count: 3
    expect(page).to have_content stations[0].name
  end

  scenario "when I click on a station" do
    visit stations_path
    click_link stations.first.name
    expect(current_path).to eq station_path(stations.first)
  end

  scenario "when viewing a station" do
    visit station_path stations.first
    expect(page).to have_content stations.first.name
  end

  scenario "when I create a new station with valid input" do
    admin_session
    visit stations_path
    click_link "New Station"
    fill_in "Name", with: "Sample Station"
    fill_in "Hardware ID", with: "123456789"
    expect {
      click_button "Create Station"
    }.to change(Station, :count).by(+1)
    expect(current_path).to eq station_path(Station.last)
  end

  scenario "when I click edit on a station" do
    admin_session
    visit stations_path
    first('.station').click_link('Edit')
    expect(current_path).to include edit_station_path(stations[0])
  end

  scenario "when I edit a page" do
    admin_session
    stations[0].save!
    visit edit_station_path(stations[0])
    fill_in 'Latitude', with: 999
    click_button 'Update'
    expect(current_path).to eq station_path(stations[0].slug)
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

end