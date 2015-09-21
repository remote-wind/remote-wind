require 'spec_helper'

describe "stations/index", type: :view do

  let (:station) { build_stubbed(:station) }

  let :stations do
    allow(station).to receive(:observations).and_return([build_stubbed(:observation)])
    [station]
  end 

  let! (:rendered_view) do
    stub_user_for_view_test
    assign(:stations, stations)
    render
    rendered
  end
  
  it "has the currect contents" do
    expect(rendered_view).to have_selector '.speed'
    expect(rendered_view).to have_selector '.direction'
    expect(rendered_view).to match /[s|S]tations/
    expect(rendered_view).to have_selector('.station')
    expect(rendered_view).to_not have_link 'Edit'
    expect(rendered_view).to_not have_link 'Delete'
    expect(rendered_view).to have_selector '.breadcrumbs .root', text: 'Home'
    expect(rendered_view).to have_selector '.breadcrumbs .current', text: 'Stations'  
  end
  
end
