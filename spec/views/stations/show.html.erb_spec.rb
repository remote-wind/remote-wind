require 'spec_helper'

describe "stations/show" do

  let (:station) {
    build_stubbed(:station, timezone: "Brisbane", speed_calibration: 0.5143, user: build_stubbed(:user))
  }

  let (:measures) do
    measures = [build_stubbed(:measure, station: station, created_at: Time.new(2000) - 25.minutes)]
    measures << build_stubbed(:measure, station: station, created_at: Time.new(2000) - 15.minutes)
    measures << build_stubbed(:measure, station: station, created_at: Time.new(2000) - 5.minutes)
    measures.sort_by! { |m| m.created_at }
  end

  before(:each) do
    stub_user_for_view_test
    assign(:station, station)
    assign(:measures, measures)
  end

  subject {
    render
    rendered
  }

  it { should have_selector('h1', :text => station.name )}

  context "when not an admin" do
    it { should_not have_link 'Delete' }
    it { should_not have_link 'Clear all measures for this station' }
  end

  context "when an admin" do
    before { @ability.can :manage, Station }
    it { should have_link 'Edit' }
    it { should have_link 'Clear all measures for this station' }
  end

  describe "breadcumbs" do
    it { should have_selector '.breadcrumbs .root', text: 'Home' }
    it { should have_selector '.breadcrumbs a', text: 'Stations' }
    it { should have_selector '.breadcrumbs .current', text: station.name }
  end

  describe "map" do
    it { should have_selector "#map_canvas .marker .title", text: station.name }
    it { should have_selector "#map_canvas .marker[data-lat='#{station.lat}']" }
    it { should have_selector "#map_canvas .marker[data-lon='#{station.lon}']" }
  end

  describe "meta" do
    it { should have_link 'j_random_user', href: user_path(station.user.to_param) }
    it { should have_selector ".station-meta .created-at td:last", text: station.time_to_local(station.created_at) }
    it { should have_selector ".station-meta .updated-at td:last", text: station.time_to_local(station.updated_at) }
    it { should have_selector ".station-meta .latitude td:last", text: station.latitude }
    it { should have_selector ".station-meta .longitude td:last", text: station.longitude }
    it { should have_selector ".station-meta .timezone td:last", text: station.timezone }
    it { should have_selector ".station-meta .visible td:last", text: "yes" }
    it { should have_selector ".station-meta .speed-calibration td:last", text: 0.51 }
  end

end