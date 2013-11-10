require 'spec_helper'

describe "stations/new" do
  before(:each) do
    assign(:station, stub_model(Station).as_new_record)
  end

  it "renders new station form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", stations_path, "post" do
    end
  end
end
