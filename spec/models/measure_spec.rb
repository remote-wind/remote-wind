require 'spec_helper'

describe Measure do

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
      m = Measure.new(s: 100)
      expect(m.speed).to eq 1
    end

    specify "normalize direction" do
      m = Measure.new(d: 100)
      expect(m.direction).to eq 10
    end

    specify "round direction properly" do
      m = Measure.new(d: "2838")
      expect(m.direction).to eq 284

    end

    specify "normalize min" do
      m = Measure.new(min: 100)
      expect(m.min).to eq 1
    end

    specify "normalize max" do
      m = Measure.new(max: 100)
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
    let(:measure) do
      create(:measure, params)
    end

    it "calibrates measures after save" do
      m = Measure.new(params)
      m.save!
      expect(m.calibrated).to be_true
    end

    it "multiplies speed" do
      measure.calibrate!
      expect(measure.speed).to eq 5
    end

    it "multiplies min speed" do
      measure.calibrate!
      expect(measure.min).to eq 5
    end

    it "multiplies max speed" do
      measure.calibrate!
      expect(measure.max).to eq 5
    end

    it "sets calibrated property" do
      measure.calibrate!
      expect(measure.calibrated).to be_true
    end

    it "calibrates only once during object lifetime" do
      measure.calibrate!
      measure.calibrate!
      expect(measure.max).to eq 5
    end

    it "does not allow saving a calibrated measure" do
      measure.calibrate!
      expect {
        measure.save!
      }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Speed calbration Calibrated measures cannot be saved!")
    end
  end

  describe "calibrated?" do
    it "returns false if measure is not calibrated" do
      measure = build_stubbed(:measure)
      expect(measure.calibrated?).to be_false
    end
    it "returns true if measure is calibrated" do
      measure = build_stubbed(:measure, calibrated: true)
      expect(measure.calibrated?).to be_true
    end
  end

  it "caches speed_calibration values" do
    measure = create(:measure, station: create(:station, speed_calibration: 0.5))
    expect(measure.speed_calibration).to eq 0.5
  end

end
