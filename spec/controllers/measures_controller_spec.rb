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

    let!(:station) { create(:station) }

    it "does not accept any other format than yaml" do
      expect {
        post :create, { measure: valid_attributes, format: 'html' }
      }.to_not change(Measure, :count)
      expect(@response.response_code).to eq 400
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