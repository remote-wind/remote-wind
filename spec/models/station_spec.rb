require 'spec_helper'

describe Station do
  it { should belong_to :user }
  it { should validate_uniqueness_of :hw_id }

  let(:station) { create(:station) }

  describe 'lat' do
    it "should get latitude" do
      expect(station.lat).to eq station.latitude
    end
  end

  describe 'lat=' do
    it "should set latitude" do
      station.lat = 99
      expect(station.latitude).to eq 99
    end
  end

  describe 'lon' do
    it "should get longitude" do
      expect(station.lon).to eq station.longitude
    end
  end

  describe 'lon=' do
    it "should set longitude" do
      station.lon = 99
      expect(station.longitude).to eq 99
    end
  end

  describe 'find_timezone' do
    subject { station.find_timezone }
    it { should eq 'London' }
  end

  describe 'set_timezone!' do

    it "should lookup timezone upon creating a station" do
      expect(station.timezone).to eq 'London'
    end

  end

end
