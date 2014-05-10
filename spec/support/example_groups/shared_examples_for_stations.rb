shared_examples "a station" do
  describe "attributes" do
    its(:id)        { should eq attributes[:id] }
    its(:latitude)  { should eq attributes[:latitude] }
    its(:longitude) { should eq attributes[:longitude] }
    its(:name)      { should eq attributes[:name] }
    its(:slug)      { should eq attributes[:slug] }
    its(:url)       { should include station_url(attributes[:slug]) }
    its(:path)      { should eq station_path(attributes[:slug]) }
    its(:offline) { should eq attributes[:offline] }
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
