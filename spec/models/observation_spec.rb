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

describe Observation, :type => :model do

  let(:station) { create(:station) }

  before do
    # makes it possible to use stubbed stations
    allow_any_instance_of(Observation).to receive(:update_station)
  end

  describe "attributes" do
    describe "validations" do
      it { is_expected.to validate_presence_of :station }
      it { is_expected.to validate_numericality_of :speed }
      it { is_expected.to validate_numericality_of :direction }
      it { is_expected.to validate_numericality_of :max_wind_speed }
      it { is_expected.to validate_numericality_of :min_wind_speed }
      it { is_expected.to validate_numericality_of :speed_calibration }
    end

    describe "aliases" do
      it { is_expected.to respond_to :i }
      it { is_expected.to respond_to :s }
      it { is_expected.to respond_to :d }
      it { is_expected.to respond_to :max }
      it { is_expected.to respond_to :min }
    end
  end

  describe "Ardiuno adapted setters should" do
    specify "normalize speed" do
      expect(Observation.new(s: 100).speed).to eq 1
    end

    specify "normalize direction" do
      expect(Observation.new(d: 100).direction).to eq 10
    end

    specify "round direction properly" do
      expect(Observation.new(d: "2838").direction).to eq 284
    end

    specify "normalize min" do
      expect(Observation.new(min: 100).min).to eq 1
    end

    specify "normalize max" do
      expect(Observation.new(max: 100).max).to eq 1
    end
  end

  describe "#calibrate!" do
    let(:station) { create(:station, speed_calibration: 0.5) }
    let(:params) do
      {
        station: station,
        speed: 10,
        min_wind_speed: 10,
        max_wind_speed: 10
      }
    end
    let(:observation) { create(:observation, params) }


    it "calibrates observations after save" do
      expect(observation.calibrated).to be_truthy
    end

    it "multiplies speed" do
      expect(observation.speed).to eq 5
    end

    it "multiplies min speed" do
      expect(observation.min).to eq 5
    end

    it "multiplies max speed" do
      expect(observation.max).to eq 5
    end

    it "sets calibrated property" do
      expect(observation.calibrated).to be_truthy
    end

    it "calibrates only once during object lifetime" do
      observation.calibrate!
      expect(observation.max).to eq 5
    end

    it "calibrates observation on find" do
      create(:observation, station: build_stubbed(:station))
      expect(Observation.last.calibrated?).to be_truthy
    end

    it "does not allow saving a calibrated observation" do
      observation.calibrate!
      observation.save
      expect(observation.valid?).to be_falsey
      expect(observation.errors[:speed_calibration].to_s).to match("Calibrated observations cannot be saved!")
    end
  end

  describe "calibrated?" do
    it "returns false if observation is not calibrated" do
      observation = build_stubbed(:observation)
      expect(observation.calibrated?).to be_falsey
    end
    it "returns true if observation is calibrated" do
      observation = build_stubbed(:observation, calibrated: true)
      expect(observation.calibrated?).to be_truthy
    end
  end

  it "updates station last observation received at time after saving" do
    skip('test is broken and should be done on station side')
  end

end
