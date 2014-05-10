require 'spec_helper'

describe StationsHelper do

  let(:station) { build_stubbed(:station) }

  describe "#clear_observations_button" do

    subject(:button) { helper.clear_observations_button(station) }

    it "should have the correct classes" do
      expect(button).to have_selector 'a.tiny.button.alert'
    end

    it "has the correct text" do
      expect(button).to have_selector "a", text: "Clear all observations for this station?"
    end

    it 'has method=DELETE' do
      expect(button).to have_selector 'a[data-method="delete"]'
    end

    it "has a data-confirm attibute" do
      expect(button).to match /data-confirm\=\"*.?\"/
    end
  end

  describe "#station_header" do
    subject(:heading) { helper.station_header(station) }
    it "contains the stations name" do
      expect(heading).to eq (station.name)
    end

    context "when station is down" do
      subject(:heading)  { helper.station_header(build_stubbed(:station, offline: true)) }
      it "says 'offline'" do
        expect(heading).to have_selector 'em', text: 'offline'
      end
    end
  end

  describe "#station_coordinates" do

    let(:station) { build_stubbed(:station, lat: 50, lon: 40) }
    subject(:data_attrs) { helper.station_coordinates(station) }

    it { should match 'data-lat="50"' }
    it { should match 'data-lng="40"' }

  end
end
