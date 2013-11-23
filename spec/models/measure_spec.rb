require 'spec_helper'

describe Measure do

  describe "attributes" do
    it { should belong_to :station }
    it { should respond_to :speed }
    it { should respond_to :direction }
    it { should respond_to :max_wind_speed }
    it { should respond_to :min_wind_speed }
    it { should respond_to :temperature }
  end

  describe "validations" do
    it { should validate_presence_of :station }
    it { should validate_numericality_of :speed }
    it { should validate_numericality_of :direction }
    it { should validate_numericality_of :max_wind_speed }
    it { should validate_numericality_of :min_wind_speed }
  end

end
