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
    it { should respond_to :down }
    it { should respond_to :balance }

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

  describe ".send_low_balance_alerts" do

    context "when a station has a low balance" do

      let!(:station) {
        create(:station, :balance => 3, :user => create(:user))
      }

      it "logs a warning" do
        Rails.logger.should_receive(:warn).with(/Station low balance alert: Station \d* only has 3.0 kr left! Notifing owner/)
        Station.send_low_balance_alerts()
      end

      it "sends an email to user" do
        StationMailer.should_receive(:notify_about_low_balance)
        Station.send_low_balance_alerts()
      end
    end

    context "when a station does not have a low balance" do

      let!(:station) {
        create(:station, :balance => 99, :user => create(:user))
      }

      it "does not send an email" do
        StationMailer.should_not_receive(:notify_about_low_balance)
        Station.send_low_balance_alerts()
      end
    end
  end

  describe ".send_down_alerts" do

    context "when a station has not received measures in more than 15 minutes ago" do

      let!(:station) {
        station = create(:station, :user => create(:user))
        station.measures.create(attributes_for(:measure, :created_at => Time.new(2001)))
        station
      }

      it "logs a warning" do
        Rails.logger.should_receive(:warn).with(/Station down alert: Station \d* is down/)
        Station.send_down_alerts()
      end

      it "sends an email to user" do
        StationMailer.should_receive(:notify_about_station_down)
        Station.send_down_alerts()
      end
    end

    context "when a station measures in less than 15 minutes ago" do

      let!(:station) {
        station = create(:station, :user => create(:user))
        station.measures.create(attributes_for(:measure))
        station
      }

      it "does not send an email" do
        StationMailer.should_not_receive(:notify_about_station_down)
        Station.send_down_alerts()
      end
    end
  end

end