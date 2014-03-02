require 'spec_helper'

describe "pages/home" do

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

  let :measure do
    stations[0].current_measure
  end

  before(:each) do
    stub_user_for_view_test
  end

  subject do
    stations
    render
    rendered
  end

end