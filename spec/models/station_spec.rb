require 'spec_helper'
require 'timezone/error'

describe Station do

  let(:station) { create(:station) }

  describe "relations" do
    it { should have_many :measures }
    it { should belong_to :user }
  end

  describe "attributes" do
    it { should respond_to :name }
    it { should respond_to :hw_id }
    it { should respond_to :latitude }
    it { should respond_to :longitude }
    it { should respond_to :timezone }

    describe "attribute aliases" do
      it { should respond_to :lon }
      it { should respond_to :lng }
      it { should respond_to :lat }
      it { should respond_to :owner }
    end
  end

  describe "validations" do
    it { should validate_uniqueness_of :hw_id }
    it { should validate_presence_of :hw_id }
  end

  describe "#find_timezone" do
    it "should find the correct timezone" do
      expect(station.lookup_timezone).to eq "London"
    end
  end

  describe "#set_timezone!" do

    it "should set timezone on object creation given lat and lon" do
      Station.any_instance.unstub(:lookup_timezone)
      zone = double(Timezone::Zone)
      Timezone::Zone.stub(:new).and_return(zone)
      Timezone::Zone.should_receive(:new).with(:latlon => [35.6148800, 139.5813000])
      zone.stub(:active_support_time_zone).and_return('Tokyo')
      expect(create(:station, lat: 35.6148800, lon: 139.5813000).timezone).to eq "Tokyo"
    end

    it "handles exceptions from Timezone" do
      Station.any_instance.stub(:lookup_timezone).and_raise(Timezone::Error::Base)
      expect{expect(create(:station, lat: 35.6148800, lon: 139.5813000))}.to_not raise_error
    end
  end

  describe "slugging" do
    it "should slug name in absence of a slug" do
      station = create(:station, name: 'foo')
      expect(station.slug).to eq 'foo'
    end

    it "should use slug if provided" do
      station = create(:station, name: 'foo', slug: 'bar')
      expect(station.slug).to eq 'bar'
    end
  end


end