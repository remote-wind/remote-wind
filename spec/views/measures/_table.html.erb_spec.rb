require 'spec_helper'

describe "measures/_table" do

  let(:station){ create(:station) }
  let(:measures) do
    [*1..3].map! do |i|
      build_stubbed(:measure, station: station, created_at: Time.now - i.hours)
    end
  end
  let(:measure) do
    measures.first
  end

  before :each do
    assign(:station, station)
    assign(:measures, measures)
  end

  subject do
    render
    rendered
  end

  it { should have_selector ".measure", exact: measures.length }
  it { should have_selector ".measure:first .created_at", text: time_date_hours_seconds(station.time_to_local(measures.first.created_at)) }
  it { should have_selector '.speed',  text: "#{measure.speed} (#{measure.min}-#{measure.max})m/s" }
  it { should have_selector '.direction', text: degrees_and_cardinal(measure.direction) }

end