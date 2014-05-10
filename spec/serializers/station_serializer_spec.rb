require 'spec_helper'

describe StationSerializer do

  include Rails.application.routes.url_helpers

  let!(:resource) { build_stubbed(:station, slug: 'foo', offline: true) }

  it_behaves_like 'a station'

  context "when station has latest_measure" do

    let(:measure) { build_stubbed(:measure) }

    before(:each) do
      resource.latest_measure = measure
    end

    it "includes latest_measure" do
      expect(subject.latest_measure.id).to eq measure.id
    end
  end
end