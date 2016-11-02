require 'rails_helper'

describe "pages/home", type: :view do

  let! :stations do
    stations = []
    3.times do
      stations << create(:station)
    end
    stations.each do |s|
      s.observations.push(create(:observation))
    end

    assign(:stations, stations)
    stations
  end

  let :observation do
    stations[0].current_observation
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