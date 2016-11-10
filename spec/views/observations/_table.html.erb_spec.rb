require 'rails_helper'

describe "observations/_table", type: :view do

  let(:station){ create(:station) }
  let(:observations) do
    build_list(:observation, 2, station: station, created_at: Time.new(2016))
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
    expect(table).to have_selector ".created_at",
      text: "01/01 00:00"
    expect(table).to have_selector ".observation",
      count: observations.length
    expect(table).to have_selector '.speed',
      text: "#{observation.speed} (#{observation.min}-#{observation.max})m/s"
    expect(table).to have_selector '.direction',
      text: degrees_and_cardinal(observation.direction)
  end
end
