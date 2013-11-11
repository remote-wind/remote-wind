require 'spec_helper'

describe "stations/show" do
  before(:each) do
    stub_user_for_view_test
    @station = assign(:station, create(:station))
  end


  context "when not an admin" do
    subject {
      render
      rendered
    }

    it { should have_selector('h1', :text => @station.name )}
    it { should have_link 'Back' }
    it { should_not have_link 'Delete' }
  end

  context "when an admin" do

    subject {
      @ability.can :manage, Station
      render
      rendered
    }

    it { should have_link 'Edit' }
  end

end
