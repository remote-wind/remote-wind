require 'spec_helper'

describe "measures/_table" do

  let(:station){ create(:station) }
  let(:measures) do
    [*1..3].map! do |i|
      measure = create(:measure, station: station)
      measure.update_attribute(:created_at, (i - 1).hours.ago )

      measure
    end
  end

  before(:each) do
    stub_user_for_view_test
    assign(:measures, measures)
    assign(:station, station)
  end

  subject(:rendered) do
    render
    Capybara.string(rendered)
  end

  it { should have_selector 'tr', exact: 3 }
  it { should have_selector 'tr:first .created_at', text: measures.last.created_at.strftime( "%H:%M" ) }

end