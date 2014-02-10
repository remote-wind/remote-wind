require 'spec_helper'

describe "stations/index" do


  let! :stations do
    stations = []
    stations << create(:station)
    stations[0].measures.push(create(:measure))
    assign(:stations, stations)
    stations
  end
  
  before(:each) do
    stub_user_for_view_test
  end

  subject {
    render
    rendered
  }

  it { should have_selector '.speed' }
  it { should have_selector '.direction' }
  it { should match /[s|S]tations/ }
  it { should have_selector('.station') }

  context "when not an admin" do
    it { should_not have_link 'Edit' }
    it { should_not have_link 'Delete' }
  end

  describe "breadcumbs" do
    it { should have_selector '.breadcrumbs .root', text: 'Home' }
    it { should have_selector '.breadcrumbs .current', text: 'Stations' }
  end

  describe "map" do
    it { should have_selector "#map_canvas" }
    it { should have_selector '#map_canvas .marker', exact: stations.length }
    it { should have_selector "#map_canvas .marker[data-lat='#{stations[0].lat}']" }
    it { should have_selector "#map_canvas .marker[data-lon='#{stations[0].lon}']" }
  end
end
