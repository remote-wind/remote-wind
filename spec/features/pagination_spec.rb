require 'spec_helper'

feature "Pagination" do

  context "when I visit station/show" do

    let!(:station) { create(:station) }
    let!(:measures) { 3.times { create(:measure, station: station) }}

    before :each do
      visit station_path(station)
      station.measures.stub(:count).and_return(50)
    end

    it "links to more measures" do
      within "#table" do
        click_link 'More'
      end
      expect(current_path).to eq station_measures_path(station)
    end
  end
end
