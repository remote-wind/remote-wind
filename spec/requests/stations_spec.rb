require 'spec_helper'

RSpec.describe "Stations", type: :request do

  let(:station){ create(:station) }
  let(:json) { JSON.parse(response.body) }

  describe "GET /stations/find/:hw_id" do
    it "finds a station by hardware id" do
      get '/stations/find/' + station.hw_id
      expect(response).to have_http_status(200)
      expect(json).to eq({
        "id" => station.id,
        "hw_id" => station.hw_id
      })
    end
  end
end
