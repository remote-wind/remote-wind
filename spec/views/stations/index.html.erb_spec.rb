require 'spec_helper'

describe "stations/index" do
  before(:each) do
    assign(:stations, [
      stub_model(Station),
      stub_model(Station)
    ])
  end

  it "renders a list of stations" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
