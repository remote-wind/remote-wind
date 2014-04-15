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


  let(:rendered_view) do
    assign(:station, station)
    assign(:measures, measures)
    render
    rendered
  end

  it "should have the correct contents" do
    expect(rendered_view).to have_selector ".measure", exact: measures.length
    expect(rendered_view).to have_selector ".measure:first .created_at", text: time_date_hours_seconds(station.time_to_local(measures.first.created_at))
    expect(rendered_view).to have_selector '.speed',  text: "#{measure.speed} (#{measure.min}-#{measure.max})m/s"
    expect(rendered_view).to have_selector '.direction', text: degrees_and_cardinal(measure.direction)
  end

end