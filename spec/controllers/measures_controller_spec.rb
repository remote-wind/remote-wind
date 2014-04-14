require 'spec_helper'

describe MeasuresController do

  let!(:station) {  create(:station) }
  let(:measure) { create(:measure, :station => station) }
  let(:valid_attributes) {
    attributes_for(:measure, station_id: station.id)

  }

  before :each do
    sign_out :user
  end

  describe "POST 'create'" do

    let!(:station) { create(:station, user: build_stubbed(:user)) }

    it "does not accept any other format than yaml" do
     expect {
       post :create, { measure: valid_attributes, format: 'html' }
     }.to raise_exception(ActionController::UnknownFormat)
    end

    it "checks station status" do
      Station.any_instance().should_receive(:check_status!)
      post :create, { measure: valid_attributes, format: "yaml" }
    end

    context "with valid attributes" do
      it "should create a new measure" do
        expect {
          post :create, {measure: valid_attributes, format: "yaml"}
        }.to change(Measure, :count).by(1)
      end
    end

    context "with short form attributes" do
      it "should create a new measure" do
        expect {
          post :create, {m: {s: 1, d:  2, i: station.id, max: 4, min: 5}, format: "yaml"}
        }.to change(Measure, :count).by(1)
      end
    end

    context "with yaml format" do
      it "sends HTTP success" do
        post :create, { measure: valid_attributes, format: "yaml"}
        expect(response.code).to eq "200"
      end

      it "does not render a template" do
          post :create, { measure: valid_attributes, format: "yaml"}
          expect(response).to render_template nil
      end
    end

    it "updates station last_measure_received_at" do
      post :create, { measure: valid_attributes, format: "yaml"}
      expect(assigns(:station).last_measure_received_at).to eq assigns(:measure).created_at
    end

  end

  describe "GET index" do

    let(:station) { create(:station, speed_calibration: 0.5) }
    let!(:measures) { [ create(:measure, station: station, speed: 10) ] }

    context "when request is HTML" do

      it "uses the page param to paginate measures" do
        # Stub the chain to set up expection
        Station.any_instance.stub(:measures).and_return(Measure)
        Measure.stub(:order).and_return(Measure)

        Measure.should_receive(:paginate).with(page: "2").and_return([].paginate)
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

      it "assigns measures" do
        expect(assigns(:measures).to_a).to include measures.first
      end

      it "calibrates measures" do
        expect(assigns(:measures).first.speed).to eq 5
      end
    end
  end

  describe "DELETE clear" do

    before :each do
      3.times do
        station.measures.create attributes_for(:measure)
      end
    end

    context "when an unpriveleged user" do
      before { sign_in create(:user) }
      it "does not allow measures to be destoyed" do
        expect do
          delete :clear, {:station_id => station.to_param}
        end.to_not change(Measure, :count)
        bypass_rescue
      end

      it "does not allow measures to be destoyed" do
        expect do
          bypass_rescue
          delete :clear, {:station_id => station.to_param}
        end.to raise_error CanCan::AccessDenied
      end

    end

    context "when an admin" do
      before { sign_in create(:admin) }

      it "destroys the related measures" do
        delete :clear, {:station_id => station.to_param}
        expect(Measure.where("station_id = #{station.id}").count).to eq 0
      end

      it "redirects to the station" do
        delete :clear, {:station_id => station.to_param}
        expect(response).to redirect_to(station_url(station.to_param))
      end
    end
  end

  describe "DELETE 'destroy'" do

    before do
      measure #lazy load measure
    end

    context "as unpriveleged user" do
      before { sign_in create(:user) }
      it "should not allow measures to be destoyed without authorization" do
        expect do
          delete :destroy, {id: measure.to_param, station_id:  measure.station.to_param}
        end.to_not change(Measure, :count)
      end
    end

    context "as admin" do
      before { sign_in create(:admin) }

      it "destroys the requested measure" do
        expect {
          delete :destroy, { id: measure.to_param, station_id: measure.station.to_param}
        }.to change(Measure, :count).by(-1)
      end

      it "redirects to the measure list" do
        delete :destroy, { id: measure.to_param, station_id: measure.station.to_param}
        expect(response).to redirect_to(measures_url)
      end
    end
  end
end