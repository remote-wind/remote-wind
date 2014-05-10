# == Schema Information
#
# Table name: stations
#
#  id                       :integer          not null, primary key
#  name                     :string(255)
#  hw_id                    :string(255)
#  latitude                 :float
#  longitude                :float
#  balance                  :float
#  down                     :boolean
#  timezone                 :string(255)
#  user_id                  :integer
#  created_at               :datetime
#  updated_at               :datetime
#  slug                     :string(255)
#  show                     :boolean          default(TRUE)
#  speed_calibration        :float            default(1.0)
#  last_observation_received_at :datetime
#

require 'spec_helper'
require 'timezone/error'

describe Station do

  let(:station) { create(:station) }

  describe "relations" do
    it { should have_many :observations }
    it { should belong_to :user }
  end

  describe "attributes" do
    it { should respond_to :name }
    it { should respond_to :hw_id }
    it { should respond_to :latitude }
    it { should respond_to :longitude }
    it { should respond_to :timezone }
    it { should respond_to :offline }
    it { should respond_to :balance }
    it { should respond_to :zone }
    it { should respond_to :show }
    it { should respond_to :speed_calibration }
    it { should respond_to :last_observation_received_at }

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
    it { should validate_numericality_of :speed_calibration }
    it { should validate_numericality_of :balance }
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
    it "checks all the stations" do
      # prevents no user error
      Station.any_instance.stub(:check_balance)
      stations = [*1..3].map! { build_stubbed(:station) }
      stations.last.should_receive(:check_balance)
      Station.send_low_balance_alerts(stations)
    end
  end

  describe ".check_all_stations" do
    let!(:stations) { [*1..3].map! { build_stubbed(:station) } }
    it "should check each station" do
      Station.any_instance.stub(:check_status!)
      stations.last.should_receive(:check_status!)
      Station.check_all_stations(stations)
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

  describe "#get_calibrated_observations" do

    let(:station) { create(:station) }

    context "when there are observations in the last 12h" do

      let!(:observations) do
        [*1..3].map! do |i|
          observation = create(:observation, station: station)
          observation.update_attribute(:created_at, (i - 1).hours.ago )
          observation
        end
      end

      it "gets observations only within the limit" do
        expect(station.get_calibrated_observations(Time.now - 2.hours).count).to eq 2
      end

      it "defaults to 12 hours ago" do
        old_observation = create(:observation, station: station)
        old_observation.update_attribute(:created_at, 14.hours.ago )
        expect(station.get_calibrated_observations()).to_not include old_observation
      end

      it "calibrates observations" do
        expect(station.get_calibrated_observations().first.calibrated).to be true
      end
    end

    it "attempts to get observations N hours before last_observation_received if there are no observations in the last N h" do
      station.last_observation_received_at = 12.hours.ago
      observation = create(:observation, station: station)
      observation.update_attribute( :created_at, 14.hours.ago )
      expect(station.get_calibrated_observations()).to include observation
    end
  end

  describe "#current_observation" do

    let!(:observation) do
      create(:observation, station: station, speed: 777)
    end

    it "returns cached observation" do
      station.latest_observation = build_stubbed(:observation, speed: 999)
      expect(station.current_observation.speed).to eq 999
    end

    it "does not issue query if cached observation available" do
      station.latest_observation = build_stubbed(:observation, speed: 999)
      station.observations.should_not_receive(:last)
      station.current_observation
    end

    it "returns latest observation if none cached" do
      expect(station.current_observation.speed).to eq 777
    end

  end

  describe "#should_be_offline?" do

    let(:station) { create(:station, offline: true) }

    context "when station has three observations in last 24 min" do
      it "should not be down" do
        4.times { create(:observation, station: station) }
        expect(station.should_be_offline?).to be_false
      end
    end

    context "when station has less than three observations in last 24 min" do

      let(:observations) { [*1..4].map! { create(:observation, station: station) } }

      before :each do
        observations.each do |m, index|
          m.update_attribute(:created_at, 1.hours.ago )
        end
      end

      it "should be offline" do
        create(:observation, station: station)
        expect(station.should_be_offline?).to be_true
      end
    end
  end

  describe "check_status!" do

    let(:user) { build_stubbed(:user) }

    context "when station was online" do

      let(:station){ create(:station, offline: false, user: user) }

      context "and station should be online" do
        # Essentially nothing should happen here.
        # test that notifications are not sent
        before(:each) do
          station.stub(:should_be_offline?).and_return(false)
        end

        it "station not be offline" do
          station.check_status!
          expect(station.offline).to be_false
        end

        it "should not notify" do
          station.should_not_receive("notify_offline")
          station.check_status!
        end
      end

      context "and station should be offline" do
        # Essentially nothing should happen here.
        # test that notifications are not sent
        before(:each) do
          station.stub(:should_be_offline?).and_return(true)
        end

        specify "station should be offline" do
          station.check_status!
          expect(station.offline).to be_true
        end

        it "should notify that station is offline" do
          station.should_receive("notify_offline")
          station.check_status!
        end
      end
    end

    context "when station was offline" do

      let(:station){ create(:station, offline: true, user: user) }

      context "and now should be online" do
        # Essentially nothing should happen here.
        # test that notifications are not sent
        before(:each) do
          station.stub(:should_be_offline?).and_return(false)
        end

        specify "station should not be offline" do
          station.check_status!
          expect(station.offline).to be_false
        end

        it "should notify" do
          station.should_receive(:notify_online)
          station.check_status!
        end
      end

      context "and now should be offline" do
        # Essentially nothing should happen here.
        # test that notifications are not sent
        before(:each) do
          station.stub(:should_be_offline?).and_return(true)
        end

        it "should not send message" do
          station.should_not_receive(:notify_online)
          station.check_status!
        end

        specify "station not be offline" do
          station.check_status!
          expect(station.offline).to be_true
        end
      end
    end
  end

  describe "#notify_offline" do

    let(:user) { build_stubbed(:user) }
    let(:station) { create(:station, user: user) }

    it "should log error" do
      Rails.logger.should_receive(:warn).with("Station alert: #{station.name} is now down")
      station.notify_offline
    end

    it "should create notification" do
      expect {
        station.notify_offline
      }.to change(Notification, :count).by(1)
    end

    it "should create notification with correct attributes" do
      Notification.should_receive(:create).with(
          user: user,
          level: :warn,
          message: "#{station.name} is down.",
          event: "station_down"
      )
      station.notify_offline
    end

    it "should send email" do
      StationMailer.should_receive(:notify_about_station_offline)
      station.notify_offline
    end

    it "should send email if notified in last 12h" do
      create(:notification, message: "#{station.name} is down.")
      StationMailer.should_receive(:notify_about_station_offline)
      station.notify_offline
    end
  end

  describe "#notify_online" do
    let(:user) { build_stubbed(:user) }
    let(:station) { create(:station, user: user) }

    it "should send message" do
      StationMailer.should_receive(:notify_about_station_online)
      station.notify_online
    end

    it "should log" do
      Rails.logger.should_receive(:info).with("Station alert: #{station.name} is now up")
      station.notify_online
    end

    it "should create notification" do
      expect {
        station.notify_online
      }.to change(Notification, :count).by(1)
    end

    it "should create notification with correct attributes" do
      Notification.should_receive(:create).with(
          user: user,
          level: :info,
          message: "#{station.name} is up.",
          event: "station_up"
      )
      station.notify_online
    end

    it "should send email if not notified in 12h" do
      StationMailer.should_receive(:notify_about_station_offline)
      station.notify_offline
    end

    it "should send email if notified in last 12h" do
      create(:notification, message: "#{station.name} is down.")
      StationMailer.should_receive(:notify_about_station_offline)
      station.notify_offline
    end
  end

  describe "#check_balance" do

    context "when balance is low" do
      let(:station){ build_stubbed(:station, balance: 10, user: build_stubbed(:user)) }


      it "should return false" do
        expect(station.check_balance).to be_false
      end

      it "should log notice" do
        Rails.logger.should_receive(:info)
            .with("#{station.name} has a low balance, only 10.0 kr left.")
        station.check_balance
      end

      it "should send email" do
        StationMailer.should_receive(:notify_about_low_balance)
        station.check_balance
      end

      it "should only create email if not yet notified" do
        create(:notification, message: "#{station.name} has a low balance, only 10.0 kr left.")
        StationMailer.should_not_receive(:notify_about_low_balance)
        station.check_balance
      end

      it "should create a notification" do
        expect {
          station.check_balance
        }.to change(Notification, :count).by(1)
      end

      it "should create a notification with the correct attributes" do
        station.check_balance
        note = Notification.last
        expect(note.message).to eq "#{station.name} has a low balance, only 10.0 kr left."
        expect(note.event).to eq "station_low_balance"
      end

    end

    context "when balance is high" do

      let(:station){ build_stubbed(:station, balance: 999, user: build_stubbed(:user)) }

      it "should return true" do
        expect(station.check_balance).to be_true
      end

      it "should not log notice" do
        Rails.logger.should_not_receive(:info)
        station.check_balance
      end

      it "should not send email" do
        StationMailer.should_not_receive(:notify_about_low_balance)
        station.check_balance
      end

      it "should not create a notification" do
        expect {
          station.check_balance
        }.to_not change(Notification, :count)
      end
    end
  end
end
