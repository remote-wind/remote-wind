require 'spec_helper'

describe "stations/edit" do
  before(:each) do
    @station = assign(:station, stub_model(Station))
  end

  it "renders the edit station form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", station_path(@station), "post" do
    end
  end
end
