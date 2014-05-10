require 'spec_helper'

describe StationSerializer do

  include Rails.application.routes.url_helpers

  let!(:resource) { build_stubbed(:station, slug: 'foo', offline: true) }

  it_behaves_like 'a station'

  context "when station has latest_observation" do

    let(:observation) { build_stubbed(:observation) }

    before(:each) do
      resource.latest_observation = observation
    end

    it "includes latest_observation" do
      expect(subject.latest_observation.id).to eq observation.id
    end
  end
end