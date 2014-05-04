shared_examples "a station" do
  describe "attributes" do
    it "has the correct attributes" do
      expect(subject.id).to eq station.id
      expect(subject.latitude).to eq station.latitude
      expect(subject.longitude).to eq station.longitude
      expect(subject.name).to eq station.name
      expect(subject.slug).to eq station.slug
      expect(subject.url).to eq station_url(station)
      expect(subject.path).to eq station_path(station)
    end
  end
end

shared_examples "a station form" do
  describe "station form" do

    before(:each) do
      stub_user_for_view_test
      assign(:station, build_stubbed(:station))
      render
    end

    subject { rendered }

    it "has the correct fields" do
      expect(subject).to have_field "Name"
      expect(subject).to have_field "Slug"
      expect(subject).to have_field "Latitude"
      expect(subject).to have_field "Longitude"
      expect(subject).to have_field "Hardware ID"
      expect(subject).to have_field "Show"
      expect(subject).to have_field "Speed Calibration"
    end
  end
end
