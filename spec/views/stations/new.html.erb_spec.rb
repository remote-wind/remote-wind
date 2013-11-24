require 'spec_helper'

describe "stations/new" do

  before(:each) do
    stub_user_for_view_test
    assign(:station, stub_model(Station).as_new_record)
  end


  describe 'form' do

    it "renders new station form" do
      render
      # Run the generator again with the --webrat flag if you want to use webrat matchers
      assert_select "form[action=?][method=?]", stations_path, "post"
    end

    subject do
      render
      rendered
    end

    it { should have_field "Name" }
    it { should have_field "Slug" }
    it { should have_field "Latitude" }
    it { should have_field "Longitude" }
    it { should have_field "Hardware ID" }
    it { should have_select "Owner" }

  end
end
