describe "stations/_form", type: :view do

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
    expect(subject).to have_field "Speed Calibration"
    expect(subject).to_not have_field "Show"
  end
end
