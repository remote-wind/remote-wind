require 'spec_helper'

feature "Pagination" do

  context "when I visit station/show" do

    let!(:station) { create(:station) }
    let!(:observations) { 3.times { create(:observation, station: station) }}

    before :each do
      visit station_path(station)
      station.observations.stub(:count).and_return(50)
    end

    it "links to more observations" do
      within "#table" do
        click_link 'More'
      end
      expect(current_path).to eq station_observations_path(station)
    end
  end
end
