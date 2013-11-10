require 'spec_helper'

describe "stations/show" do
  before(:each) do
    @station = assign(:station, stub_model(Station))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
