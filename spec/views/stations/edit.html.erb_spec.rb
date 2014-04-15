require 'spec_helper'

describe "stations/edit" do

  describe 'form' do

    let! (:form) do
      stub_user_for_view_test
      assign(:station, build_stubbed(:station))
      render
      rendered
    end

    it "has the correct fields" do
      expect(form).to have_field "Name"
      expect(form).to have_field "Slug"
      expect(form).to have_field "Latitude"
      expect(form).to have_field "Longitude"
      expect(form).to have_field "Hardware ID"
      expect(form).to have_field "Show"
      expect(form).to have_field "Speed Calibration"
    end
  end

end