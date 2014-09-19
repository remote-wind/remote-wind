require 'spec_helper'

describe "observations/_table" do

  let(:station){ create(:station) }
  let(:observations) do
    [*1..3].map! do |i|
      build_stubbed(:observation, station: station, created_at: Time.now - i.hours)
    end
  end
  let(:observation) do
    observations.first
  end

  subject(:table) do
    render partial: "observations/table",
           locals: { observations: observations, station: station }
    rendered
  end

  it "should have the correct contents" do
    expect(table).to have_selector ".observation", exact: observations.length
    expect(table).to have_selector '.speed',  text: "#{observation.speed} (#{observation.min}-#{observation.max})m/s"
    expect(table).to have_selector '.direction', text: degrees_and_cardinal(observation.direction)
  end

end