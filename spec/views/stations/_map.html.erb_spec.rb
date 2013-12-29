require 'spec_helper'

describe "stations/_map" do

  let(:station) { create(:station) }
  let(:measure) { create(:measure, station: station) }

  before(:each) do
    station.measures.create(attributes_for(:measure))
    stub_user_for_view_test
    assign(:stations, [station])
  end

  subject (:page) do
    render
    rendered
  end

  it { should have_selector(".map-canvas") }
  it { should have_selector(".marker") }

  specify "the map marker should have the correct min speed" do
    expect(page).to have_selector(".measure[data-min-speed='#{measure.min}']")
  end

  specify "the map marker should have the correct max speed" do
    expect(page).to have_selector(".measure[data-max-speed='#{measure.max}']")
  end

  specify "the map marker should have the correct direction" do
    expect(page).to have_selector(".measure[data-direction='#{measure.direction}']")
  end

end

