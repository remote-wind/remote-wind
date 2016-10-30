require 'spec_helper'

RSpec.describe "Stations", type: :request do

  let(:station){ create(:station, status: :active) }
  let(:json) { JSON.parse(response.body) }

  describe "GET /stations/find/:hw_id" do
    it "finds a station by hardware id" do
      get '/stations/find/' + station.hw_id, format: :json
      expect(response).to have_http_status(200)
      expect(json).to eq({
        "id" => station.id
      })
    end
  end

  describe "GET /stations" do

    context 'with observations' do
      let(:observation) { json.first["observations"].first }
      before do
        [20, 15, 10, 5, 1].map do |time|
          Timecop.travel( time.minutes.ago ) do
            station.observations.create( attributes_for(:observation) )
          end
        end
      end

      it "should include the correct observation" do
        get '/stations.json'
        expect(observation["id"]).to eq station.observations.last.id
      end
    end

    it 'includes stations with no observations' do
      station
      get '/stations.json'
      expect(json.first['id']).to eq station.id
    end
  end


end
