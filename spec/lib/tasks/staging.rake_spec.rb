require 'spec_helper'

describe 'staging:cull' do

  include_context "rake"

  let!(:measure) { create(:measure, station: create(:station)) }

  it "clears all measures older than 2 days" do
    measure.created_at = 3.days.ago
    subject.invoke
    expect(Measure.where("created_at < ?", 2.days.ago).count).to eq 0
  end

  it "does not remove measures newer than 2 days" do
    expect {
      subject.invoke
    }.to_not change(Measure, :count)
  end

end