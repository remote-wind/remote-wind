require 'spec_helper'

describe "stations/new" do


  describe 'form' do

    let!(:page) do
      stub_user_for_view_test
      assign(:station, stub_model(Station).as_new_record)
      render
      rendered
    end
    
    
    it "has the correct contents" do

      expect(page).to have_selector 'form[action="%s"][method=post]' % [stations_path]
      expect(page).to have_field "Name"
      expect(page).to have_field "Slug"
      expect(page).to have_field "Latitude"
      expect(page).to have_field "Longitude"
      expect(page).to have_field "Hardware ID"
      expect(page).to have_select "Owner"

    end
  end
end
