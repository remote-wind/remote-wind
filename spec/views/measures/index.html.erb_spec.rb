require 'spec_helper'

describe "measures/index.html.erb" do
  before(:each) do
    stub_user_for_view_test
    @station = assign(:station, create(:station))
    @measures = assign(:measures, [create(:measure, :station_id => 1)] )
  end

  subject {
    render
    rendered
  }

  it { should have_selector '.station',        text: @measures[0].station.name }
  it { should have_selector '.speed',          text: @measures[0].speed }
  it { should have_selector '.direction',      text: "E (90°)" }
  it { should have_selector '.max_wind_speed', text: @measures[0].max_wind_speed }
  it { should have_selector '.min_wind_speed', text: @measures[0].min_wind_speed }
  it { should have_selector '.created_at',     text: @measures[0].created_at.to_s }

end
