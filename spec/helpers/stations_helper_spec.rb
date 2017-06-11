require 'rails_helper'
require 'nokogiri'

describe StationsHelper, type: :helper do

  # stub helper so that we can test that controller and action name classes
  # are added.
  before do
    allow(helper).to receive(:controller_name).and_return('foo')
    allow(helper).to receive(:action_name).and_return('bar')
  end

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

    context "when station is not active" do
      let(:station) { build_stubbed(:station, status: :deactivated) }
      subject(:heading)  { helper.station_header(station) }
      it "shows the stations status" do
        expect(heading).to have_selector 'em', text: 'deactivated'
      end
    end
  end

  describe "#station_coordinates" do
    let(:station) { build_stubbed(:station, lat: 50, lon: 40) }
    subject(:data_attrs) { helper.station_coordinates(station) }
    it { is_expected.to match 'data-lat="50"' }
    it { is_expected.to match 'data-lng="40"' }
  end

  describe "#readable_duration" do
    let(:duration) { 1.hour + 5.minutes + 10.seconds }
    it "includes hours seconds and minutes" do
      expect(helper.readable_duration(duration)).to eq '01:05:10'
    end
  end

  describe "#station_status_indicator" do
    let(:station) { Station.new(status: :not_initialized) }
    subject { helper.station_status_indicator(station) }
    it "can create any element" do
      output = helper.station_status_indicator(station, element: :div)
      expect(output).to have_selector 'div.not_initialized'
    end
    it "passes on keyword args" do
      output = helper.station_status_indicator(station, foo: "bar")
      expect(output).to have_selector 'span[foo="bar"]'
    end
    context "not_initialized" do
      let(:station) { Station.new(status: :not_initialized ) }
      it { should have_selector 'span', text: 'Not initialized' }
      it { should have_selector '.not_initialized', text: 'Not initialized' }
    end
    context "deactivated" do
      let(:station) { Station.new(status: :deactivated ) }
      it { should have_selector '.deactivated', text: 'Not in use' }
    end
    context "unresponsive"  do
      let(:station) { Station.new(status: :unresponsive ) }
      it { should have_selector '.unresponsive', text: 'Unresponsive' }
    end
    context "active" do
      let(:station) { Station.new(status: :active ) }
      it { should have_selector '.active', text: 'Ok' }
    end
  end

  describe "#leaflet_tag" do

    subject { helper.leaflet_tag }
    it { should have_selector "#map_canvas.map-canvas" }
    it { should have_selector "#map_canvas.foo-bar" }

    it "yields to a block" do
      helper.leaflet_tag
    end

    context "when passed a block" do
      subject do
        helper.leaflet_tag do
          helper.content_tag :span, "Hello World!"
        end
      end
      it "yeilds the block" do
        expect(subject).to have_content "Hello World!"
      end
    end

    context "when passed a station" do
      let(:s) { build_stubbed(:station) }
      subject { helper.leaflet_tag(s) }
      it { should have_selector "#map_canvas[data-lat='#{s.latitude}']" }
      it { should have_selector "#map_canvas[data-lng='#{s.longitude}']" }
    end

    context "when passed extra css classes" do
      it "adds classes to container" do
        expect( helper.leaflet_tag(class: 'foo') ).to have_selector('.foo')
        expect(
          helper.leaflet_tag(class: %w{ foo bar })
        ).to have_selector('.foo.bar')
      end
    end
  end
end
