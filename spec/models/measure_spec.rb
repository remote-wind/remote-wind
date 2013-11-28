require 'spec_helper'

describe Measure do

  describe "attributes" do
    it { should belong_to :station }
    it { should respond_to :speed }
    it { should respond_to :direction }
    it { should respond_to :max_wind_speed }
    it { should respond_to :min_wind_speed }

    describe "aliases" do
      it { should respond_to :i }
      it { should respond_to :s }
      it { should respond_to :d }
      it { should respond_to :max }
      it { should respond_to :min }
    end

  end

  describe "Ardiuno adapted setters should" do



    it "normalize speed" do
      m = Measure.new(s: 100)
      expect(m.speed).to eq 1
    end

    it "normalize direction" do
      m = Measure.new(d: 100)
      expect(m.direction).to eq 10
    end

    it "normalize min" do
      m = Measure.new(min: 100)
      expect(m.min).to eq 1
    end

    it "normalize max" do
      m = Measure.new(max: 100)
      expect(m.max).to eq 1
    end
  end

  describe "validations" do
    it { should validate_presence_of :station }
    it { should validate_numericality_of :speed }
    it { should validate_numericality_of :direction }
    it { should validate_numericality_of :max_wind_speed }
    it { should validate_numericality_of :min_wind_speed }
  end

end
