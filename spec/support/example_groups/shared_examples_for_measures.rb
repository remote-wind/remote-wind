shared_examples "a measure" do
  describe "attributes" do
    it "has the correct attributes" do
      expect(subject.id).to eq measure.id
      expect(subject.speed).to eq measure.speed
      expect(subject.direction).to eq measure.direction
      expect(subject.max_wind_speed).to eq measure.max_wind_speed
      expect(subject.min_wind_speed).to eq measure.min_wind_speed
      expect(subject.tstamp).to eq 946681200 #
      expect(subject.created_at).to eq "1999-12-31T23:00:00Z"
    end
  end
end