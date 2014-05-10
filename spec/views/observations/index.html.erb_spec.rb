require 'spec_helper'

describe "observations/index" do

  let!(:station) { build_stubbed(:station) }

  let!(:observations) do
    # page, per_page, total_entries
    WillPaginate::Collection.create(1, 5, 10) do |pager|
      pager.replace([*1..10].map! { build_stubbed(:observation, station: station) })
    end
  end


  let!(:rendered_view) do
    Observation.stub(:last).and_return(observations.last)
    Observation.stub(:created_at).and_return(Time.new(2000))

    assign(:station, station)
    assign(:observations, observations)
    stub_user_for_view_test
    view.stub(:url_for)
    render
    rendered
  end

  it "has the correct contents" do
    expect(rendered_view).to match /Latest observations for #{station.name.capitalize}/
    expect(rendered_view).to match /Latest observation received at #{observations.last.created_at.strftime("%H:%M")}/i
    expect(rendered_view).to have_selector '.pagination'
    expect(rendered_view).to have_selector '.current'
    expect(rendered_view).to have_selector '.previous_page'
    expect(rendered_view).to have_selector '.next_page'
  end
  
end