require 'spec_helper'

describe "measures/show.html.erb" do

  before(:each) do
    stub_user_for_view_test
    @station = assign(:station, create(:station))
    @measure = assign(:measure, create(:measure, :station_id => 1))
  end

  subject {
    render
    rendered
  }

  it { should have_selector '.station',        text: @measure.station.name }
  it { should have_selector '.speed',          text: @measure.speed }
  it { should have_selector '.direction',      text: "E (90°)" }
  it { should have_selector '.max_wind_speed', text: @measure.max_wind_speed }
  it { should have_selector '.min_wind_speed', text: @measure.min_wind_speed }
  it { should have_selector '.created_at',     text: @measure.created_at.to_s }
  it { should have_selector '.temperature',    text: @measure.temperature }
end
