# == Schema Information
#
# Table name: observations
#
#  id                :integer          not null, primary key
#  station_id        :integer
#  speed             :float
#  direction         :float
#  max_wind_speed    :float
#  min_wind_speed    :float
#  temperature       :float
#  created_at        :datetime
#  updated_at        :datetime
#  speed_calibration :float
#

require 'spec_helper'

describe Observation do

  before do
    # makes it possible to use stubbed stations
    Observation.any_instance.stub(:update_station)
  end



  describe "attributes" do

    describe "validations" do
      it { should validate_presence_of :station }
      it { should validate_numericality_of :speed }
      it { should validate_numericality_of :direction }
      it { should validate_numericality_of :max_wind_speed }
      it { should validate_numericality_of :min_wind_speed }
      it { should validate_numericality_of :speed_calibration }
    end

    describe "aliases" do
      it { should respond_to :i }
      it { should respond_to :s }
      it { should respond_to :d }
      it { should respond_to :max }
      it { should respond_to :min }
    end
  end



  describe "Ardiuno adapted setters should" do
    specify "normalize speed" do
      m = Observation.new(s: 100)
      expect(m.speed).to eq 1
    end

    specify "normalize direction" do
      m = Observation.new(d: 100)
      expect(m.direction).to eq 10
    end

    specify "round direction properly" do
      m = Observation.new(d: "2838")
      expect(m.direction).to eq 284

    end

    specify "normalize min" do
      m = Observation.new(min: 100)
      expect(m.min).to eq 1
    end

    specify "normalize max" do
      m = Observation.new(max: 100)
      expect(m.max).to eq 1
    end
  end

  describe "#calibrate!" do
    let(:station) { create(:station, speed_calibration: 0.5) }
    let(:params){{
        station: station,
        speed: 10,
        min_wind_speed: 10,
        max_wind_speed: 10
    }}
    let(:observation) do
      create(:observation, params)
    end

    it "calibrates observations after save" do
      m = Observation.new(params)
      m.save!
      expect(m.calibrated).to be_true
    end

    it "multiplies speed" do
      observation.calibrate!
      expect(observation.speed).to eq 5
    end

    it "multiplies min speed" do
      observation.calibrate!
      expect(observation.min).to eq 5
    end

    it "multiplies max speed" do
      observation.calibrate!
      expect(observation.max).to eq 5
    end

    it "sets calibrated property" do
      observation.calibrate!
      expect(observation.calibrated).to be_true
    end

    it "calibrates only once during object lifetime" do
      observation.calibrate!
      observation.calibrate!
      expect(observation.max).to eq 5
    end

    it "calibrates observation on find" do
      create(:observation, station: build_stubbed(:station))
      expect(Observation.last.calibrated?).to be_true
    end

    it "does not allow saving a calibrated observation" do
      observation.calibrate!
      expect {
        observation.save!
      }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Speed calibration Calibrated observations cannot be saved!")
    end
  end

  describe "calibrated?" do
    it "returns false if observation is not calibrated" do
      observation = build_stubbed(:observation)
      expect(observation.calibrated?).to be_false
    end
    it "returns true if observation is calibrated" do
      observation = build_stubbed(:observation, calibrated: true)
      expect(observation.calibrated?).to be_true
    end
  end

  it "caches speed_calibration values" do
    observation = create(:observation, station: create(:station, speed_calibration: 0.5))
    expect(observation.speed_calibration).to eq 0.5
  end


  it "updates station last observation recieved at time after saving" do
    Observation.any_instance.unstub(:update_station)
    station = create(:station)
    expected = Time.new(2000)
    Time.stub(:now).and_return(expected)
    observation = create(:observation, station: station)

    expect(station.last_observation_received_at).to eq expected

  end

end
