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
        Rails.logger.should_receive(:warn).with(/Station alert: Station \d* no new measures in 15 min => down/)
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

    context "when there are measures in the last 12h" do

      let!(:measures) do
        [*1..3].map! do |i|
          measure = create(:measure, station: station)
          measure.update_attribute(:created_at, (i - 1).hours.ago )
          measure
        end
      end

      it "gets measures only within the limit" do
        expect(station.get_calibrated_measures(Time.now - 2.hours).count).to eq 2
      end

      it "defaults to 12 hours ago" do
        old_measure = create(:measure, station: station)
        old_measure.update_attribute(:created_at, 14.hours.ago )
        expect(station.get_calibrated_measures()).to_not include old_measure
      end

      it "calibrates measures" do
        expect(station.get_calibrated_measures().first.calibrated).to be true
      end
    end

    it "attempts to get measures N hours before last_measure_received if there are no measures in the last N h" do
      station.last_measure_received_at = 12.hours.ago
      measure = create(:measure, station: station)
      measure.update_attribute( :created_at, 14.hours.ago )
      expect(station.get_calibrated_measures()).to include measure
    end
  end

  describe "#current_measure" do
    let!(:measure) { create(:measure, station: station) }
    it "calibrates measure" do
      expect(station.current_measure.calibrated).to be_true
    end
  end

  describe "should_be_down?" do

    let(:station) { create(:station, down: true) }


    context "when station has no previous measures" do
      it "should not be down" do
        expect(station.should_be_down?).to be_false
      end
    end


    context "when station has three or more old measures" do

      context "and three last within 15 minutes" do
        before(:each) do
          create(:measure, :station => station)
          create(:measure, :station => station, :created_at => 15.minutes.ago)
          create(:measure, :station => station, :created_at => 10.minutes.ago)
          create(:measure, :station => station, :created_at => 5.minutes.ago)
        end

        it "should not be down" do
          expect(station.should_be_down?).to be_false
        end
      end

      context "and the two latest within 60 minutes" do
        before(:each) do
          create(:measure, :station => station)
          create(:measure, :station => station, :created_at => 65.minutes.ago)
          create(:measure, :station => station, :created_at => 59.minutes.ago)
          create(:measure, :station => station, :created_at => 54.minutes.ago)
        end
        it "should not be down" do
          expect(station.should_be_down?).to be_false
        end
      end

      context "and has three or more old measures that are older than 60 minutes" do
        before(:each) do
          create(:measure, :station => station)
          create(:measure, :station => station, :created_at => 75.minutes.ago)
          create(:measure, :station => station, :created_at => 70.minutes.ago)
          create(:measure, :station => station, :created_at => 65.minutes.ago)
        end
        it "should not be down" do
          expect(station.should_be_down?).to be_false
        end
      end

      context "but not within 15 minutes and not two last within an hour" do
        before(:each) do
          create(:measure, :station => station)
          create(:measure, :station => station, :created_at => 80.minutes.ago)
          create(:measure, :station => station, :created_at => 75.minutes.ago)
          create(:measure, :station => station, :created_at => 70.minutes.ago)
          create(:measure, :station => station, :created_at => 25.minutes.ago)
        end
        it "should not be down" do
          pending "test is broken?"
          expect(station.should_be_down?).to be_true
        end
      end
    end
  end

  describe "check_status!" do


    let(:user) { build_stubbed(:user) }

    context "when station was up" do

      let(:station){ create(:station, down: false, user: user) }

      it "logs that its checking station" do
        station.stub(:should_be_down?).and_return(false)
        Rails.logger.should_receive(:info).with("Checking station #{station.name}")
        station.check_status!
      end


      context "and station should be up" do
        # Essentially nothing should happen here.
        # test that notifications are not sent
        before(:each) do
          station.stub(:should_be_down?).and_return(false)
        end

        it "should not send message" do
          station.check_status!
          StationMailer.should_not_receive("notify_about_station_down")
        end

        it "station not be down" do
          station.check_status!
          expect(station.down).to be_false
        end
      end

      context "and station should be down" do
        # Essentially nothing should happen here.
        # test that notifications are not sent
        before(:each) do
          station.stub(:should_be_down?).and_return(true)
        end

        specify "station should be down" do
          station.check_status!
          expect(station.down).to be_true
        end

        it "should send message" do
          StationMailer.should_receive("notify_about_station_down")
          station.check_status!
        end

        it "should log error" do
          Rails.logger.should_receive(:warn).with("Station alert: #{station.name} is now down")
          station.check_status!
        end

        it "should create notification" do
          expect {
            station.check_status!
          }.to change(Notification, :count).by(1)
        end

        it "should create notification with correct attributes" do
          Notification.should_receive(:create).with(
              user: user,
              level: :warn,
              message: "#{station.name} is down.",
              event: "station_down"
          )
          station.check_status!
        end

      end

    end

    context "when station was down" do

      let(:station){ create(:station, down: true, user: user) }

      context "and now should be up" do
        # Essentially nothing should happen here.
        # test that notifications are not sent
        before(:each) do
          station.stub(:should_be_down?).and_return(false)
        end

        specify "station should not be down" do
          station.check_status!
          expect(station.down).to be_false
        end

        it "should send message" do
          StationMailer.should_receive("notify_about_station_up")
          station.check_status!
        end

        it "should log" do
          Rails.logger.should_receive(:info).with("Station alert: #{station.name} is now up")
          station.check_status!
        end

        it "should create notification" do
          expect {
            station.check_status!
          }.to change(Notification, :count).by(1)
        end

        it "should create notification with correct attributes" do
          Notification.should_receive(:create).with(
              user: user,
              level: :info,
              message: "#{station.name} is up.",
              event: "station_up"
          )
          station.check_status!
        end

      end

      context "and now should be down" do
        # Essentially nothing should happen here.
        # test that notifications are not sent
        before(:each) do
          station.stub(:should_be_down?).and_return(true)
        end


        it "should not send message" do
          StationMailer.should_not_receive("notify_about_station_down")
          StationMailer.should_not_receive("notify_about_station_up")
          station.check_status!
        end

        specify "station not be down" do
          station.check_status!
          expect(station.down).to be_true
        end
      end
    end
  end
end