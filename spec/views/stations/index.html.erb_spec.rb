require 'spec_helper'

describe "stations/index" do


  let! :stations do
    stations = []
    3.times do
      stations << create(:station)
    end
    stations.each do |s|
      s.measures.push(create(:measure))
    end

    assign(:stations, stations)
    stations
  end
  
  before(:each) do
    stub_user_for_view_test
    assign(:stations, [
      stub_model(Station),
      stub_model(Station)
    ])

  end

  context "when not an admin" do
    subject {
      render
      rendered
    }

    it { should have_selector '.speed' }
    it { should have_selector '.direction' }

    it { should match /[s|S]tations/ }
    it { should have_selector('.station', :minimum => 2) }
    it { should_not have_link 'Edit' }
    it { should_not have_link 'Delete' }
  end

  context "when an admin" do

    subject {
      @ability.can :manage, Station
      render
      rendered
    }

    it { should have_link 'Edit' }
    it { should have_link 'Delete' }
  end
end
