require 'spec_helper'



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
  end

  describe "validations" do
    it { should validate_uniqueness_of :hw_id }
    it { should validate_presence_of :hw_id }
  end

  describe "#lat" do
    it { should respond_to :lat }

    it "should get latitude" do
      expect(station.lat).to eq station.latitude
    end
  end

  describe "#lat=" do
    it "should set latitude" do
      station.lat = 10
      expect(station.latitude).to eq 10
    end
  end

  describe "#lon" do
    it { should respond_to :lon }
    it "should get longitude" do
      expect(station.lon).to eq station.longitude
    end
  end

  describe "#lon=" do
    it "should set longitude" do
      station.lon = 10
      expect(station.longitude).to eq 10
    end
  end

  describe "#find_timezone" do
    it "should find the correct timezone" do
      expect(station.find_timezone).to eq "London"
    end
  end

  describe "#set_timezone!" do
    #it "should set timezone on object creation given lat and lon" do
    #  Station::zone_class.stub(:active_support_time_zone).and_return('Tokyo')
    #  expect(create(:station, lat: 35.6148800, lon: 139.5813000).timezone).to eq "Tokyo"
    #end
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