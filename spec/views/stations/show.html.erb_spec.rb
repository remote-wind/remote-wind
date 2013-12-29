require 'spec_helper'

describe "stations/show" do

  let (:station) {
    build_stubbed(:station)
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
    subject {
      @ability.can :manage, Station
      render
      rendered
    }
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

  describe "table ordering" do
    it { should have_selector 'table.measures .measure:first .created_at', text: "12/31 22:55" }
    it { should have_selector 'table.measures .measure:nth-child(2) .created_at', text: "12/31 22:45" }
    it { should have_selector 'table.measures .measure:nth-child(3) .created_at', text: "12/31 22:35" }
  end

end
