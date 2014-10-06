# == Schema Information
#
# Table name: stations
#
#  id                           :integer          not null, primary key
#  name                         :string(255)
#  hw_id                        :string(255)
#  latitude                     :float
#  longitude                    :float
#  balance                      :float
#  offline                      :boolean
#  timezone                     :string(255)
#  user_id                      :integer
#  created_at                   :datetime
#  updated_at                   :datetime
#  slug                         :string(255)
#  show                         :boolean          default(TRUE)
#  speed_calibration            :float            default(1.0)
#  last_observation_received_at :datetime
#

require 'spec_helper'
require 'timezone/error'

describe Station, :type => :model do

  let(:station) { create(:station) }

  describe "relations" do
    it { is_expected.to have_many :observations }
    it { is_expected.to belong_to :user }
  end

  describe "attributes" do
    describe "attribute aliases" do
      it { is_expected.to respond_to :lon }
      it { is_expected.to respond_to :lng }
      it { is_expected.to respond_to :lat }
      it { is_expected.to respond_to :owner }
    end
  end

  describe "validations" do
    it { is_expected.to validate_uniqueness_of :hw_id }
    it { is_expected.to validate_presence_of :hw_id }
    it { is_expected.to validate_numericality_of :speed_calibration }
    it { is_expected.to validate_numericality_of :balance }
  end

  describe "#set_timezone!" do
    before :each do
      allow_any_instance_of(Station).to receive(:lookup_timezone).and_call_original
      @zone = double(Timezone::Zone)
      allow(@zone).to receive(:zone).and_return("Europe/London")
      allow(Timezone::Zone).to receive(:new).and_return(@zone)
    end

    it "should set timezone on object creation given lat and lon" do
      expect(Timezone::Zone).to receive(:new).with(:latlon => [35.6148800, 139.5813000])
      expect(create(:station, lat: 35.6148800, lon: 139.5813000).timezone).to eq "Europe/London"
    end

    it "handles exceptions from Timezone" do
      allow_any_instance_of(Station).to receive(:lookup_timezone).and_raise(Timezone::Error::Base)
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
      allow_any_instance_of(Station).to receive(:check_balance)
      stations = [*1..3].map! { build_stubbed(:station) }
      expect(stations.last).to receive(:check_balance)
      Station.send_low_balance_alerts(stations)
    end
  end

  describe ".check_all_stations" do
    let!(:stations) { [*1..3].map! { build_stubbed(:station) } }
    it "should check each station" do
      allow_any_instance_of(Station).to receive(:check_status!)
      expect(stations.last).to receive(:check_status!)
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
      expect(station.observations).not_to receive(:last)
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
        expect(station.should_be_offline?).to be_falsey
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
        expect(station.should_be_offline?).to be_truthy
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
          allow(station).to receive(:should_be_offline?).and_return(false)
        end

        it "station not be offline" do
          station.check_status!
          expect(station.offline).to be_falsey
        end

        it "should not notify" do
          expect(station).not_to receive("notify_offline")
          station.check_status!
        end
      end

      context "and station should be offline" do
        # Essentially nothing should happen here.
        # test that notifications are not sent
        before(:each) do
          allow(station).to receive(:should_be_offline?).and_return(true)
        end

        specify "station should be offline" do
          station.check_status!
          expect(station.offline).to be_truthy
        end

        it "should notify that station is offline" do
          expect(station).to receive("notify_offline")
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
          allow(station).to receive(:should_be_offline?).and_return(false)
        end

        specify "station should not be offline" do
          station.check_status!
          expect(station.offline).to be_falsey
        end

        it "should notify" do
          expect(station).to receive(:notify_online)
          station.check_status!
        end
      end

      context "and now should be offline" do
        # Essentially nothing should happen here.
        # test that notifications are not sent
        before(:each) do
          allow(station).to receive(:should_be_offline?).and_return(true)
        end

        it "should not send message" do
          expect(station).not_to receive(:notify_online)
          station.check_status!
        end

        specify "station not be offline" do
          station.check_status!
          expect(station.offline).to be_truthy
        end
      end
    end
  end

  describe "#notify_offline" do

    let(:user) { build_stubbed(:user) }
    let(:station) { create(:station, user: user) }

    it "should log error" do
      expect(Rails.logger).to receive(:warn).with("Station alert: #{station.name} is now down")
      station.notify_offline
    end

    it "should create notification" do
      expect {
        station.notify_offline
      }.to change(Notification, :count).by(1)
    end

    it "should create notification with correct attributes" do
      expect(Notification).to receive(:create).with(
          user: user,
          level: :warn,
          message: "#{station.name} is down.",
          event: "station_down"
      )
      station.notify_offline
    end

    it "should send email" do
      expect(StationMailer).to receive(:offline)
      station.notify_offline
    end

    it "should send email if notified in last 12h" do
      create(:notification, message: "#{station.name} is down.")
      expect(StationMailer).to receive(:offline)
      station.notify_offline
    end
  end

  describe "#notify_online" do
    let(:user) { build_stubbed(:user) }
    let(:station) { create(:station, user: user) }

    it "should send message" do
      expect(StationMailer).to receive(:online)
      station.notify_online
    end

    it "should log" do
      expect(Rails.logger).to receive(:info).with("Station alert: #{station.name} is now up")
      station.notify_online
    end

    it "should create notification" do
      expect {
        station.notify_online
      }.to change(Notification, :count).by(1)
    end

    it "should create notification with correct attributes" do
      expect(Notification).to receive(:create).with(
          user: user,
          level: :info,
          message: "#{station.name} is up.",
          event: "station_up"
      )
      station.notify_online
    end

    it "should send email if not notified in 12h" do
      expect(StationMailer).to receive(:offline)
      station.notify_offline
    end

    it "should send email if notified in last 12h" do
      create(:notification, message: "#{station.name} is down.")
      expect(StationMailer).to receive(:offline)
      station.notify_offline
    end
  end

  describe "#check_balance" do

    context "when balance is low" do
      let(:station){ build_stubbed(:station, balance: 10, user: build_stubbed(:user)) }

      it "should return false" do
        expect(station.check_balance).to be_falsey
      end
      it "should log notice" do
        expect(Rails.logger).to receive(:info)
            .with("#{station.name} has a low balance, only 10.0 kr left.")
        station.check_balance
      end
      it "should send email" do
        expect(StationMailer).to receive(:low_balance)
        station.check_balance
      end
      it "should only create email if not yet notified" do
        create(:notification, message: "#{station.name} has a low balance, only 10.0 kr left.")
        expect(StationMailer).not_to receive(:low_balance)
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
        expect(station.check_balance).to be_truthy
      end
      it "should not log notice" do
        expect(Rails.logger).not_to receive(:info)
        station.check_balance
      end
      it "should not send email" do
        expect(StationMailer).not_to receive(:low_balance)
        station.check_balance
      end
      it "should not create a notification" do
        expect {
          station.check_balance
        }.to_not change(Notification, :count)
      end
    end
  end

  describe "#next_observation_expected_in" do
    let(:station){ build_stubbed(:station) }
    it "should give number of seconds until next observation" do
      allow(station).to receive(:last_observation_received_at).and_return(2.minutes.ago)
      expect(station.next_observation_expected_in).to eq 3.minutes
    end
    it "should never give more than 5 minutes" do
      allow(station).to receive(:last_observation_received_at).and_return(10.minutes.ago)
      expect(station.next_observation_expected_in).to eq 5.minutes
    end
  end

  describe "scopes" do
    before(:each) { 3.times { station.observations.create(attributes_for :observation) } }
    describe ".with_latest_observation" do
      it "eager loads the latest observation" do
        stations = Station.with_latest_observation.load
        observations = stations.last.observations
        expect(observations.size).to eq 1
        expect(observations.loaded?).to be true
      end
    end
    describe ".with_observations" do
      it "eager loads the latest observation" do
        stations = Station.with_observations(2).load
        observations = stations.last.observations
        expect(observations.size).to eq 2
        expect(observations.loaded?).to be true
      end
    end
  end

  describe "changing calibration" do
    before { station.observations.create(attributes_for :observation, speed: 2) }
    it "should cascade to observations" do
      station.update(speed_calibration: 1.5)
      expect(station.observations.last.speed_calibration).to eq 1.5
      expect(station.observations.last.speed).to eq 3
    end
  end
end
