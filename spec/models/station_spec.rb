require 'rails_helper'

RSpec.describe Station, type: :model do

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
    end

    it do
      should define_enum_for(:status).with(
        [:not_initialized, :deactivated, :unresponsive, :active]
      )
    end
  end

  describe "validations" do
    xit { is_expected.to validate_uniqueness_of :hw_id }
    xit { is_expected.to validate_presence_of :hw_id }
  end

  describe "#timezone" do
    it "has a default timezone" do
      expect(Station.new.timezone).to eq 'Europe/Stockholm'
    end

    it "validates the timezone" do
      station = Station.new(timezone: 'foo')
      station.valid?
      expect(station.errors).to have_key :timezone
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
      stations = build_stubbed_list(:station, 3) do |s|
        expect(s).to receive(:check_balance)
      end
      Station.send_low_balance_alerts(stations)
    end
  end

  describe ".check_all_stations" do
    it "should check each station" do
      stations = build_stubbed_list(:station, 3) do |s|
        expect(s).to receive(:check_status!)
      end
      Station.check_all_stations(stations)
    end
  end

  describe "#time_to_local" do
    let(:time) { Time.new(2013).utc }

    it "converts a Time to local offset" do
      station.timezone = "America/New_York"
      expect(station.time_to_local(time)).to eq time.in_time_zone("America/New_York")
    end
    it "does not break if there is no zone" do
      t = Time.new(2013)
      station.timezone = nil
      expect(station.time_to_local(t)).to eq time.in_time_zone("UTC")
    end
  end

  describe "#current_observation" do

    let!(:observation) do
      create(:observation, station: station, speed: 777)
    end

    it "returns cached observation" do
      station.latest_observation = LatestObservation.new(speed: 999, min_wind_speed: 990, max_wind_speed: 1999)
      expect(station.current_observation.speed).to eq 999
    end

    it "does not issue query if cached observation available" do
      station.latest_observation = LatestObservation.new(speed: 999, min_wind_speed: 990, max_wind_speed: 1999)
      expect(station.observations).not_to receive(:last)
      station.current_observation
    end

    it "returns latest observation if none cached" do
      expect(station.current_observation.speed).to eq 777
    end
  end

  describe "#is_unresponsive?" do

    let(:station) do
      # Fakes that station is old to avoid false positives
      Timecop.travel(1.month.ago){ create(:station, status: :unresponsive) }
    end

    context "a new station" do
      let(:station){ create(:station, status: :unresponsive)  }
      it "has a grace peroid where one observation will make it active" do
        create(:observation, station: station)
        expect(station.is_unresponsive?).to be_falsey
      end
    end

    context "when station has three observations in last 24 min" do
      before { create_list(:observation, 4, station: station) }
      it "is responsive" do
        expect(station.is_unresponsive?).to be_falsey
      end
    end

    context "when station has less than three observations in last 24 min" do
      before {
        create_list(:observation, 4, station: station)
      }
      it "is unresponsive" do
        Timecop.travel(Time.now + 45.minutes) do
          create(:observation, station: station)
          expect(station.is_unresponsive?).to be_truthy
        end
      end
    end

    describe "sampling rate" do
      let!(:observations) do
        [*1..4].map do |i|
          create(:observation, station: station, created_at: (i*10).minutes.ago)
        end
      end

      it "takes the sampling_rate into account" do
        expect(station.observations.length).to eq 4
        expect(station.created_at).to be_within(1.minute).of(1.month.ago)
        station.sampling_rate = 5.minutes
        expect(station.is_unresponsive?).to eq true
      end

      it "takes the sampling_rate into account 2" do
        station.sampling_rate = 10.minutes
        expect(station.is_unresponsive?).to eq false
      end
    end
  end

  describe "check_status!" do

    let(:station) do |ex|
      Timecop.travel(1.month.ago) do
        create(:station, status: ex.metadata[:status])
      end
    end
    let(:user) { build_stubbed(:user) }

    context "when station was deactivated", status: :deactivated do
      context "and starts to respond" do
        before(:each) do
          allow(station).to receive(:is_unresponsive?).and_return(false)
          station.check_status!
        end
        it "makes the station active" do
          expect(station.active?).to eq true
        end
      end

      context "and is not responding" do
        before(:each) do
          allow(station).to receive(:is_unresponsive?).and_return(true)
          station.check_status!
        end
        it "does not change the status of the station" do
          expect(station.deactivated?).to eq true
        end
      end
    end

    context "when station was active", status: :active do
      let(:notifier) { Services::Notifiers::StationOffline }

      context "and is still responsive" do
        # Essentially nothing should happen here.
        # test that notifications are not sent
        before(:each) do
          allow(station).to receive(:is_unresponsive?).and_return(false)
        end

        it "does not have initended side effects" do
          expect(notifier).to_not receive(:call)
          station.check_status!
          expect(station.active?).to eq true
        end
      end

      context "and is not responding" do
        # Essentially nothing should happen here.
        # test that notifications are not sent
        before(:each) do
          allow(station).to receive(:is_unresponsive?).and_return(true)
        end

        it "sets the status to unresponsive" do
          station.check_status!
          expect(station.unresponsive?).to eq true
        end

        it "notifies the owners" do
          expect(notifier).to receive(:call)
            .with(station)
          station.check_status!
        end
      end
    end

    context "when station was unresponsive", status: :unresponsive do
      let(:notifier) { Services::Notifiers::StationOnline }
      context "and starts responding" do
        # Essentially nothing should happen here.
        # test that notifications are not sent
        before(:each) do
          allow(station).to receive(:is_unresponsive?).and_return(false)
        end

        it "makes the station active" do
          station.check_status!
          expect(station.active?).to eq true
        end

        it "should notify" do
          expect(notifier).to receive(:call).with(station)
          station.check_status!
        end
      end

      context "and is still not responding" do
        # Essentially nothing should happen here.
        # test that notifications are not sent
        before(:each) do
          allow(station).to receive(:is_unresponsive?).and_return(true)
        end

        it "should not send message" do
          expect(notifier).not_to receive(:call).with(station)
          station.check_status!
        end

        it "remains unresponsive" do
          station.check_status!
          expect(station.unresponsive?).to eq true
        end
      end
    end
  end

  describe "#check_balance" do

    context "when balance is low" do
      let(:station){ build_stubbed(:station, balance: 10, user: build_stubbed(:user)) }

      it "should return false" do
        expect(station.check_balance).to be_falsey
      end

      it "notifies the user" do
        expect(Services::Notifiers::LowBalance).to receive(:call).with(station)
        station.check_balance
      end
    end

    context "when balance is high" do
      let(:station){ build_stubbed(:station, balance: 999, user: build_stubbed(:user)) }

      it "should return true" do
        expect(station.check_balance).to be_truthy
      end
    end
  end

  describe "#next_observation_expected_in" do
    let(:station){ build_stubbed(:station) }
    it "gives number of seconds until next observation" do
      allow(station).to receive(:last_observation_received_at).and_return(2.minutes.ago)
      expect(station.next_observation_expected_in).to eq 3.minutes
    end
    it "gives a negative number if overdue" do
      allow(station).to receive(:last_observation_received_at).and_return(10.minutes.ago)
      expect(station.next_observation_expected_in).to eq -5.minutes
    end
  end

  describe ".with_observations" do
    before do |ex|
      [15, 10, 5, 1].map do |time|
        Timecop.travel( time.minutes.ago ) do
          station.observations.create(attributes_for :observation)
        end
      end
    end

    it "eager loads the latest observation" do
      stations = Station.with_observations
      expect(stations.last.latest_observation)
    end

    it "eager loads multiple observations" do
      stations = Station.with_observations(2).load
      expect(stations.last.observations.loaded?)
      expect(stations.last.observations.length).to eq 2
    end

    it "includes stations that have no observations" do
      new_station = create(:station)
      stations = Station.with_observations(2)
      expect(stations).to include new_station
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


  describe "load_observations!" do
    let(:station) { create(:station) }
    before(:each) {
      station.observations.create(attributes_for :observation)
    }
    it "loads observations" do
      observations = station.load_observations!(50)
      expect(observations.loaded?).to be_truthy
    end
  end

  describe 'latest_observation callbacks' do
    it 'updates last_observation_received_at when observation is added' do
      expect {
        station.latest_observation = LatestObservation.create(attributes_for :observation)
      }.to change(station, :last_observation_received_at)
    end

    it "touches station when observation is recieved" do
      expect {
        station.latest_observation = LatestObservation.create(attributes_for(:observation))
      }.to change(station, :updated_at)
    end
  end

  describe "#low_balance?" do
    it 'returns false if the balance is above 15 sek' do
      station = build_stubbed(:station, balance: 30)
      expect(station.low_balance?).to be_falsy
    end

    it 'returns true if the balance is below 15 sek' do
      station = build_stubbed(:station, balance: 5)
      expect(station.low_balance?).to be_truthy
    end
  end

  describe '#sampling_rate' do
    let(:station) { build_stubbed(:station)  }
    subject { station.sampling_rate }
    it { should be_a ActiveSupport::Duration }
  end

  describe "#observations_per_day" do
    subject{ build_stubbed(:station, sampling_rate: 1.hour) }
    its(:observations_per_day) { should eq 24 }
  end
end
