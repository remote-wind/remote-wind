require 'rails_helper'

describe "stations/show", type: :view do
  let(:user) { build_stubbed(:user) }
  let(:observation) { build_stubbed(:observation, created_at: Time.new(2000) ) }

  let (:station) do
    build_stubbed(:station,
                  speed_calibration: 0.5143,
                  user: user,
                  updated_at: Time.new(2000),
                  observations: [ build_stubbed(:observation, created_at: Time.new(2000) ) ],
                  status: :active
    )
  end

  before(:each) do
    allow(Time).to receive(:now).and_return(Time.new(2000) - 2.hours)
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
    # Spec is broken here.
    xit "has the correct timestamps" do
      expect(page).to have_selector ".station-meta .created-at td:last", text: "23:00"
      expect(page).to have_selector ".station-meta .updated-at td:last", text: "23:00"
      expect(page).to have_selector ".station-meta .last-observation-received-at td:last", text: "23:00"
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
