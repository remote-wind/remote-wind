require 'spec_helper'

describe "stations/index" do

  let(:station) { build_stubbed(:station) }

  before(:each) do
    assign(:stations, [station])
    render template: "stations/index.json.jbuilder"
  end

  let(:json) { JSON.parse(response) }

  it "has the correct number of stations" do
    expect(json.size).to eq 1
  end

  describe "first station in array" do
    subject { OpenStruct.new(json.first) }
    it_behaves_like "a station"
  end

end