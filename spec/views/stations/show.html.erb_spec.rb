require 'rails_helper'

describe "stations/show", type: :view do
  let(:user) { build_stubbed(:user) }
  let(:observation) { build_stubbed(:observation, created_at: Time.new(2000) ) }

  let(:observations) do
    Timecop.travel(Time.new(2016)) do

    end
  end

  let (:station) do
    Timecop.freeze(Time.new(2016)) do
      build_stubbed(:station,
        speed_calibration: 0.5143,
        user: user,
        created_at: 1.hour.ago,
        updated_at: 30.minutes.ago,
        observations: [ build_stubbed(:observation, created_at: Time.now ) ],
        status: :active
      )
    end
  end

  before(:each) do
    stub_user_for_view_test
    assign(:station, station)
  end

  let(:page) do
    render
    rendered
  end

  it "has the correct content" do
    expect(page).to have_selector('h1', text: station.name)
  end

  context "when not an admin" do
    it "does not have any destructive buttons" do
      expect(page).to_not have_link 'Delete'
      expect(page).to_not have_link 'Clear all observations for this station'

    end
  end

  context "when an admin" do
    before { @ability.can :manage, Station }
    it "has admin buttons" do
      expect(page).to have_link 'Edit'
      expect(page).to have_link 'Clear all observations for this station'
    end
  end

  describe "breadcumbs" do
    it "has the correct breadcrumbs" do
      expect(page).to have_selector '.breadcrumbs .root', text: 'Home'
      expect(page).to have_selector '.breadcrumbs a', text: 'Stations'
      expect(page).to have_selector '.breadcrumbs .current', text: station.name
    end
  end

  describe "meta" do
    it "has the correct timestamps" do
      expect(page).to have_selector ".station-meta .created-at td:last", text: "12/31 23:00"
      expect(page).to have_selector ".station-meta .updated-at td:last", text: "12/31 23:30"
      expect(page).to have_selector ".station-meta .last-observation-received-at td:last", text: "12/31 23:30"
    end

    it "has the correct metadata" do
      expect(page).to have_link user.nickname, href: user_path(station.user.to_param)
      expect(page).to have_selector ".station-meta .latitude td:last", text: station.latitude
      expect(page).to have_selector ".station-meta .longitude td:last", text: station.longitude
      expect(page).to have_selector ".station-meta .timezone td:last", text: station.timezone
      expect(page).to have_selector ".station-meta .speed-calibration td:last", text: 0.51
      expect(page).to have_selector ".station-meta .status td:last", text: "active"
    end
  end

end
