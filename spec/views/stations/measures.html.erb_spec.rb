require 'spec_helper'

describe "stations/measures" do

  let! :station do
    station = create(:station)
    assign(:station, station)
    station
  end

  let! :measures do
    3.times do
      3.times do
        station.measures.create attributes_for(:measure)
      end
    end
    assign(:measures, station.measures)
    station.measures
  end

  before(:each) do
    stub_user_for_view_test
  end

  subject {
    render
    rendered
  }

  it { should match /Latest measures for #{station.name.capitalize}/ }
  it { should match /Latest measurement recieved at #{measures.last.created_at.to_s}/ }
  it { should have_selector '.speed',          text: measures[0].speed }
  it { should have_selector '.direction',      text: measures[0].direction }
  it { should have_selector '.max_wind_speed', text: measures[0].max_wind_speed }
  it { should have_selector '.min_wind_speed', text: measures[0].min_wind_speed }
  it { should have_selector '.created_at',     text: measures[0].created_at.to_s }

end