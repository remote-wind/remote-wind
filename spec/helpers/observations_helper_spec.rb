require 'rails_helper'

describe ObservationsHelper, type: :helper do

  describe "#degrees_and_cardinal" do
    subject do
      degrees_and_cardinal(5)
    end

    it { is_expected.to eq "N (5°)" }
  end

  describe "speed_min_max" do

    let(:observation){ { speed: 1, min_wind_speed: 2, max_wind_speed: 3} }

    it "formats the wind speed values according to speed(min/max)" do
      expect(speed_min_max(observation)).to eq "1 (2-3)m/s"
    end

  end

  describe "#time_in_24h" do
    it "outputs hours and minutes" do
      expect(time_in_24h Time.new(2002, 10, 31, 13, 22, 2)).to eq "13:22"
    end
  end

  describe "#time_date_hours_seconds" do

    it "gives hour and minutes when time is today" do
      time = 5.minutes.ago
      expect(time_date_hours_seconds(time)).to eq time.strftime("%H:%M")
    end

    it "includes date when time is not today" do
      time = 25.hours.ago
      expect(time_date_hours_seconds(time)).to eq time.strftime("%m/%d %H:%M")
    end

  end

end