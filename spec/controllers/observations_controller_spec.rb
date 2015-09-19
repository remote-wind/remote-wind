require 'spec_helper'

describe ObservationsController, :type => :controller do

  let(:user) { create(:user) }
  let(:station) {  create(:station, user: user ) }
  let(:observation) { create(:observation, station: station) }
  let(:valid_attributes) { attributes_for(:observation, station_id: station.id) }

  before(:each) { sign_out :user }

  describe "POST 'create'" do

    it "does not accept any other format than yaml" do
     expect {
       post :create, { observation: valid_attributes, format: 'html' }
     }.to raise_exception(ActionController::UnknownFormat)
    end

    it "checks station status" do
      expect_any_instance_of(Station).to receive(:check_status!)
      post :create, { observation: valid_attributes, format: "yaml" }
    end

    context "with valid attributes" do
      it "should create a new observation" do
        expect {
          post :create, {observation: valid_attributes, format: "yaml"}
        }.to change(Observation, :count).by(1)
      end
    end

    context "with short form attributes" do
      it "should create a new observation" do
        expect {
          post :create, {m: {s: 1, d:  2, i: station.id, max: 4, min: 5}, format: "yaml"}
        }.to change(Observation, :count).by(1)
      end
    end

    context "with yaml format" do
      it "sends HTTP success" do
        post :create, { observation: valid_attributes, format: "yaml"}
        expect(response.code).to eq "200"
      end
    end

    it "updates station last_observation_received_at" do
      post :create, { observation: valid_attributes, format: "yaml"}
      expect(assigns(:station).last_observation_received_at).to eq assigns(:observation).created_at
    end

  end

  describe "GET index" do

    let(:station) { create(:station, speed_calibration: 0.5) }
    let!(:observations) { [ create(:observation, station: station, speed: 10) ] }

    it "enables CORS" do
      get :index, station_id: station.to_param
      expect(response.headers['Access-Control-Allow-Origin']).to eq "*"
    end

    context "when request is HTML" do

      it "uses the page param to paginate observations" do
        # Stub the chain to set up expection
        allow_any_instance_of(Station).to receive(:observations).and_return(Observation)
        allow(Observation).to receive(:order).and_return(Observation)

        expect(Observation).to receive(:paginate).with(page: "2").and_return([].paginate)
        get :index, station_id: station.to_param, page: "2"
      end
    end

    context "when request is JSON" do

      before :each do
        get :index, station_id: station.to_param, format: 'json'
      end

      it "assigns station" do
        expect(assigns(:station)).to be_a(Station)
      end

      it "assigns observations" do
        expect(assigns(:observations).to_a).to include observations.first
      end

      it "calibrates observations" do
        expect(assigns(:observations).first.speed).to eq 5
      end
    end

    describe "http caching" do

      subject(:last_response) do
        get :index, station_id: station.to_param, format: 'json'
        response
      end

      it "should set the proper max age" do
        allow_any_instance_of(Station)
                .to receive(:last_observation_received_at)
                .and_return(2.minutes.ago)
        expect(last_response.cache_control[:max_age]).to eq 180.seconds
      end

      context "on the first request" do
        describe '#code' do
          subject { super().code }
          it { is_expected.to eq '200' }
        end

        describe '#headers' do
          subject { super().headers }
          it { is_expected.to have_key 'ETag' }
        end

        describe '#headers' do
          subject { super().headers }
          it { is_expected.to have_key 'Last-Modified' }
        end
      end
      context "on a subsequent request" do
        before do
          get :index, station_id: station.to_param, format: 'json'
          @etag = response.headers['ETag']
          @last_modified = response.headers['Last-Modified']
        end
        context "if it is not stale" do
          before do
            request.env['HTTP_IF_NONE_MATCH'] = @etag
            request.env['HTTP_IF_MODIFIED_SINCE'] = @last_modified
          end

          describe '#code' do
            subject { super().code }
            it { is_expected.to eq '304' }
          end
        end
        context "if station has been updated" do
          before do
            station.update_attribute(:last_observation_received_at, Time.now + 1.hour)
            request.env['HTTP_IF_NONE_MATCH'] = @etag
            request.env['HTTP_IF_MODIFIED_SINCE'] = @last_modified
          end

          describe '#code' do
            subject { super().code }
            it { is_expected.to eq '200' }
          end
        end
      end
    end
  end

  describe "DELETE clear" do

    before :each do
      3.times do
        station.observations.create attributes_for(:observation)
      end
    end

    context "an unpriveleged user" do
      before { sign_in user }
      it "does not allow observations to be destoyed" do
        expect do
          delete :clear, {:station_id => station.to_param}
        end.to_not change(Observation, :count)
      end
      it "does not allow observations to be destoyed" do
        expect do
          bypass_rescue
          delete :clear, {:station_id => station.to_param}
        end.to raise_error CanCan::AccessDenied
      end
    end

    context "when an admin" do
      before { sign_in create(:admin) }

      it "destroys the related observations" do
        delete :clear, {:station_id => station.to_param}
        expect(Observation.where("station_id = #{station.id}").count).to eq 0
      end
      it "redirects to the station" do
        delete :clear, {:station_id => station.to_param}
        expect(response).to redirect_to(station_url(station.to_param))
      end
    end
  end

  describe "DELETE 'destroy'" do

    before do
      observation #lazy load observation
    end

    context "as unpriveleged user" do
      before { sign_in user }
      it "should not allow observations to be destoyed without authorization" do
        expect do
          delete :destroy, {id: observation.to_param, station_id:  observation.station.to_param}
        end.to_not change(Observation, :count)
      end
    end

    context "as admin" do
      before { sign_in create(:admin) }

      it "destroys the requested observation" do
        expect {
          delete :destroy, { id: observation.to_param, station_id: observation.station.to_param}
        }.to change(Observation, :count).by(-1)
      end

      it "redirects to the observation list" do
        delete :destroy, { id: observation.to_param, station_id: observation.station.to_param}
        expect(response).to redirect_to(station_observations_url(observation.station))
      end
    end
  end
end