require 'spec_helper'

describe "stations/edit" do
  before(:each) do
    stub_user_for_view_test
    assign(:station, create(:station))
  end

  describe 'form' do

    subject do
      render
      rendered
    end

    it { should have_field "Name" }
    it { should have_field "Slug" }
    it { should have_field "Latitude" }
    it { should have_field "Longitude" }
    it { should have_field "Hardware ID" }

  end

end