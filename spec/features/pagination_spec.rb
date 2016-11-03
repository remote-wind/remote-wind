require 'rails_helper'

feature "Pagination" do

  context "when I visit station/show" do

    let!(:station) { create(:station) }
    let!(:observations) { 3.times { create(:observation, station: station) }}

    before :each do
      visit station_path(station)
      allow(station.observations).to receive(:count).and_return(50)
    end

    it "links to more observations" do
      within "#table" do
        click_link 'More'
      end
      expect(current_path).to eq station_observations_path(station, format: :html)
    end
  end
end
