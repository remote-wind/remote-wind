require 'spec_helper'

describe 'staging:cull' do

  include_context "rake"

  let!(:observation) { create(:observation, station: create(:station)) }

  it "clears all observations older than 2 days" do
    observation.created_at = 3.days.ago
    subject.invoke
    expect(Observation.where("created_at < ?", 2.days.ago).count).to eq 0
  end

  it "does not remove observations newer than 2 days" do
    expect {
      subject.invoke
    }.to_not change(Observation, :count)
  end

end