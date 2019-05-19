require 'rails_helper'

describe ObservationsController, type: :controller do

  let(:station) {  create(:station) }
  let(:observation) { create(:observation, station: station) }
  let(:valid_attributes) { attributes_for(:observation, station_id: station.id) }

  before(:each) { logout :user }

  describe "POST 'create'" do


    it "checks station status" do
      expect_any_instance_of(Station).to receive(:check_status!)
      post :create, params: { station_id: station, observation: valid_attributes }
    end

    context "with valid attributes" do
      it "should create a new observation" do
        expect {
          post :create, params: {station_id: station, observation: valid_attributes }
        }.to change(Observation, :count).by(1)
      end
    end

    context "with yaml format" do
      it "sends HTTP success" do
        post :create, params: { station_id: station, observation: valid_attributes }

        expect(assigns(:observation).errors.full_messages).to eq []
        #expect(response.code).to eq "200"
      end
    end

    it "updates station last_observation_received_at" do
      post :create, params: { station_id: station, observation: valid_attributes }
      expect(assigns(:station).reload.last_observation_received_at).to be_within(1.second).of(assigns(:observation).created_at)
    end

  end

  describe "GET index" do

    let(:station) { create(:station, speed_calibration: 0.5) }
    let!(:observations) { [ create(:observation, station: station, speed: 10) ] }

    def get_index(**kwargs)
      get :index, params: { station_id: station.to_param }.merge(kwargs)
    end

    it "enables CORS" do
      get_index
      expect(response.headers['Access-Control-Allow-Origin']).to eq "*"
    end

    context "when request is HTML" do
      # This test should be rewitten to not rely on allow_any_instance_of
      xit "uses the page param to paginate observations" do
        # Stub the chain to set up expection
        allow_any_instance_of(Station).to receive(:observations).and_return(Observation)
        allow(Observation).to receive(:order).and_return(Observation)
        expect(Observation).to receive(:paginate)
                                .with(page: "2").and_return([].paginate)
        get_index(page: "2")
      end
    end

    context "when request is JSON" do

      before :each do
        get_index(format: 'json')
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
        get_index(format: 'json')
        response
      end

      it "should set the proper max age" do
        allow_any_instance_of(Station)
                .to receive(:last_observation_received_at)
                .and_return(2.minutes.ago)
        expect(last_response.cache_control[:max_age]).to eq 180.seconds
      end

      context "on the first request" do
        before { get_index(format: 'json') }
        subject { response }

        its(:code){ is_expected.to eq '200' }
        its(:headers) { is_expected.to have_key 'ETag' }
        its(:headers) { is_expected.to have_key 'Last-Modified' }
      end
      context "on a subsequent request" do
        before do
          get_index(format: 'json')
          @etag = response.headers['ETag']
          @last_modified = response.headers['Last-Modified']
        end
        context "if it is not stale" do
          before do
            request.env['HTTP_IF_NONE_MATCH'] = @etag
            request.env['HTTP_IF_MODIFIED_SINCE'] = @last_modified
          end

          # unclear if test or application does not work
          xit "should be cached" do
            get_index(format: 'json')
            expect(response.code).to eq '304'
          end
        end
        context "if station has been updated" do
          before do
            create(:observation, station: station)
            request.env['HTTP_IF_NONE_MATCH'] = @etag
            request.env['HTTP_IF_MODIFIED_SINCE'] = @last_modified
          end

          describe '#code' do
            subject { super().code }
            xit { is_expected.to eq '200' }
          end
        end
      end
    end
  end

  describe "DELETE clear" do
    let(:action) { delete :clear, params: { station_id: station.to_param} }
    before :each do
      create_list(:observation, 3, station: station)
    end

    context "an unpriveleged user" do
      before { sign_in create(:user) }
      it "does not allow observations to be destoyed" do
        expect do
          action
        end.to_not change(Observation, :count)
      end
      it "does not allow observations to be destoyed" do
        expect do
          bypass_rescue
          action
        end.to raise_error Pundit::NotAuthorizedError
      end
    end

    context "when an admin" do
      before { sign_in create(:admin) }

      it "destroys the related observations" do
        action
        expect(Observation.where(station: station).count).to eq 0
      end
      it "redirects to the station" do
        action
        expect(response).to redirect_to(station_url(station.to_param))
      end
    end
  end

  describe "DELETE 'destroy'" do

    let(:action) do
       delete :destroy, params: {
         id: observation.to_param,
         station_id: observation.station.to_param
       }
    end

    before do
      observation #lazy load observation
    end

    context "as unpriveleged user" do
      before { sign_in create(:user) }
      it "should not allow observations to be destoyed without authorization" do
        expect do
          action
        end.to_not change(Observation, :count)
      end
    end

    context "as admin" do
      before { sign_in create(:admin) }

      it "destroys the requested observation" do
        expect {
          action
        }.to change(Observation, :count).by(-1)
      end

      it "redirects to the observation list" do
        action
        expect(response).to redirect_to(station_observations_url(observation.station))
      end
    end
  end
end
