require 'spec_helper'

describe "measures/index" do

  let!(:station) { build_stubbed(:station) }

  let!(:measures) do
    # page, per_page, total_entries
    WillPaginate::Collection.create(1, 10, 50) do |pager|
      pager.replace([*1..50].map! { build_stubbed(:measure, station: station) })
    end
  end


  let!(:rendered_view) do
    Measure.stub(:last).and_return(measures.last)
    assign(:station, station)
    assign(:measures, measures)
    stub_user_for_view_test
    view.stub(:url_for)
    render
    rendered
  end

  it "has the correct contents" do
    expect(rendered_view).to match /Latest measures for #{station.name.capitalize}/
    expect(rendered_view).to match /Latest measurement recieved at #{measures.last.created_at.strftime("%H:%M")}/
    expect(rendered_view).to have_selector '.pagination'
    expect(rendered_view).to have_selector '.current'
    expect(rendered_view).to have_selector '.previous_page'
    expect(rendered_view).to have_selector '.next_page'
  end
  
end