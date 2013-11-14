feature "Stations", %{
  the application should have weather stations that are viewable by users
  and  editable by admins
} do

  # @todo replace with dependency injection
  before :each do
    Station.stub(:find_timezone).and_return('London')
  end

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
    click_link "Stations"
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
    expect(current_path).to eq station_path(Station.last.id)
  end

  scenario "when I click edit on a station" do
    admin_session
    visit stations_path
    first('.station').click_link('Edit')
    expect(current_path).to include edit_station_path(1)
  end

  scenario "when I edit a page" do
    admin_session
    visit edit_station_path(1)
    fill_in 'Name', with: 'Test Station'
    click_button 'Update'
    expect(page).to have_content 'Test Station'
    expect(current_path).to eq station_path(1)
  end

  scenario "when I delete a station" do
    admin_session
    visit stations_path
    expect {
      first('.station').click_link('Delete')
    }.to change(Station, :count).by(-1)
    expect(current_path).to eq stations_path
  end

end