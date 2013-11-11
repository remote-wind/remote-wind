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

  describe "#params_to_long_form" do

    let(:params) {{s: 1, d:  2, i: 3, max: 4, min: 5}}

    subject(:result){  Measure.params_to_long_form(params) }

    it "should map to long form" do
      expect(result[:speed]).to eq params[:s]
      expect(result[:station_id]).to eq params[:i]
      expect(result[:direction]).to eq params[:d]
      expect(result[:max_wind_speed]).to eq params[:max]
      expect(result[:min_wind_speed]).to eq params[:min]
    end

  end


  describe "#params_to_short_form" do

    let(:params) {{speed: 1, direction:  2, station_id: 3, max_wind_speed: 4, min_wind_speed: 5}}

    subject(:result){  Measure.params_to_short_form(params) }

    it "should map to long form" do
      expect(result[:s]).to eq params[:speed]
      expect(result[:i]).to eq params[:station_id]
      expect(result[:d]).to eq params[:direction]
      expect(result[:max]).to eq params[:max_wind_speed]
      expect(result[:min]).to eq params[:min_wind_speed]
    end

  end

end
