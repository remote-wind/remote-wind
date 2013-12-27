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
    it { should respond_to :zone }
    it { should respond_to :show }
    it { should respond_to :speed_calibration }
    it { should respond_to :last_measure_received_at }

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

  describe "#set_timezone!" do

    before :each do
      Station.any_instance.unstub(:lookup_timezone)
      @zone = double(Timezone::Zone)
      @zone.stub(:zone).and_return("Europe/London")
      Timezone::Zone.stub(:new).and_return(@zone)
    end

    it "should set timezone on object creation given lat and lon" do
      Timezone::Zone.should_receive(:new).with(:latlon => [35.6148800, 139.5813000])
      expect(create(:station, lat: 35.6148800, lon: 139.5813000).timezone).to eq "Europe/London"
    end

    it "handles exceptions from Timezone" do
      Station.any_instance.stub(:lookup_timezone).and_raise(Timezone::Error::Base)
      expect{expect(create(:station, lat: 35.6148800, lon: 139.5813000))}.to_not raise_error
    end

    it "should set the zone attribute after initialization" do
      expect(Station.find(station.id).zone).to eq @zone
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
        StationMailer.should_receive(:notify_about_low_balance).with(station.user, station)
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

    let!(:station) {
      create(:station, :user => create(:user))
    }

    before :each  do
      Station.any_instance.stub(:measures?).and_return(true)
    end

    context "when a station has not received measures in more than 15 minutes" do

      before :each do
        Station.any_instance.stub_chain(:current_measure, :created_at).and_return(16.minutes.ago)
      end

      it "logs a warning" do
        Rails.logger.should_receive(:warn).with(/Station down alert: Station \d* is down/)
        Station.send_down_alerts()
      end

      it "sends an email to user" do
        StationMailer.should_receive(:notify_about_station_down).with(station.user, station)
        Station.send_down_alerts()
      end
    end

    context "when a has recieved station input less than 15 minutes ago" do

      before :each do
        Station.any_instance.stub_chain(:current_measure, :created_at).and_return(1.minutes.ago)
      end

      it "does not send an email" do
        StationMailer.should_not_receive(:notify_about_station_down)
        Station.send_down_alerts()
      end
    end
  end

  describe "#time_to_local_time" do

    it "converts a Time to local offset" do
      t = Time.new(2013)
      station.zone = Timezone::Zone.new :zone => "Europe/Stockholm"
      expect(station.time_to_local(t)).to eq t + 1.hours
    end

    it "does not break if there is no zone" do
      t = Time.new(2013)
      station.zone = nil
      expect(station.time_to_local(t)).to eq t
    end
  end

  describe "#get_calibrated_measures" do

    let(:station) { create(:station) }
    let(:measures) do
      measures = []
      3.times do |i|
        measures << build_stubbed(:measure, station: station )
      end
      measures
    end

    it "gets measures only within the limit" do
      pending "spec need to be finished"
      expect(station.get_calibrated_measures(time - 2.hours).count).to eq 2
    end
  end


end