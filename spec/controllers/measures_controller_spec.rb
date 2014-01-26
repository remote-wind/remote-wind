require 'spec_helper'

describe MeasuresController do

  let!(:station) {  create(:station) }
  let(:measure) { create(:measure, :station => station) }
  let(:valid_attributes) {
    attributes_for(:measure, :station_id => station.to_param )
  }

  before :each do
    sign_out :user
  end

  describe "POST 'create'" do

    let!(:station) { create(:station) }

    context "with valid attributes" do
      it "should create a new measure" do
        expect {
          post :create, {:measure => valid_attributes}
        }.to change(Measure, :count).by(1)
      end
    end

    context "with short form attributes" do
      it "should create a new measure" do
        expect {
          post :create, {:m => {s: 1, d:  2, i: station.id, max: 4, min: 5}}
        }.to change(Measure, :count).by(1)
      end
    end

    context "with yaml format" do
      it "sends HTTP success" do
        post :create, {:measure => valid_attributes, format: "yaml"}
        expect(response).to be_success
      end

      it "does not render a template" do
          post :create, {:measure => valid_attributes, format: "yaml"}
          expect(response).to render_template nil
      end
    end

    it "updates station last_measure_received_at" do
      post :create, {:measure => valid_attributes, format: "yaml"}
      expect(assigns(:station).last_measure_received_at).to eq assigns(:measure).created_at
    end

    context "sets station.down to false when receiving a new measure and" do
      it "has no previous measures" do
        station.update_attributes(down: true)
        post :create, {:measure => valid_attributes, format: "yaml"}
        expect(assigns(:station).down).to be_false
      end
      it "has three or more old measures and three last within 15 minutes" do
        station.update_attributes(down: true)
        create(:measure, :station => station, :created_at => 15.minutes.ago)
        create(:measure, :station => station, :created_at => 10.minutes.ago)
        create(:measure, :station => station, :created_at => 5.minutes.ago)
        post :create, {:measure => valid_attributes, format: "yaml"}
        expect(assigns(:station).down).to be_false
      end
      it "has three or more old measures and the two latest within 60 minutes" do
        station.update_attributes(down: true)
        create(:measure, :station => station, :created_at => 65.minutes.ago)
        create(:measure, :station => station, :created_at => 59.minutes.ago)
        create(:measure, :station => station, :created_at => 54.minutes.ago)
        post :create, {:measure => valid_attributes, format: "yaml"}
        expect(assigns(:station).down).to be_false
      end
      it "has three or more old measures that are older than 60 minutes" do
        station.update_attributes(down: true)
        create(:measure, :station => station, :created_at => 75.minutes.ago)
        create(:measure, :station => station, :created_at => 70.minutes.ago)
        create(:measure, :station => station, :created_at => 65.minutes.ago)
        post :create, {:measure => valid_attributes, format: "yaml"}
        expect(assigns(:station).down).to be_false
      end
    end
    
    context "keep station.down as true when receiving a new measure and" do
      it "has three or more old measures but not within 15 minutes and not two last within an hour" do
        station.update_attributes(down: true)
        create(:measure, :station => station, :created_at => 80.minutes.ago)
        create(:measure, :station => station, :created_at => 75.minutes.ago)
        create(:measure, :station => station, :created_at => 70.minutes.ago)
        create(:measure, :station => station, :created_at => 25.minutes.ago)
        post :create, {:measure => valid_attributes, format: "yaml"}
        expect(assigns(:station).down).to be_true
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
          delete :destroy, {:id => measure.to_param, :station_id =>  measure.station.to_param}
        end.to_not change(Measure, :count)
      end
    end

    context "as admin" do
      before { sign_in create(:admin) }

      it "destroys the requested measure" do
        expect {
          delete :destroy, {:id => measure.to_param, :station_id =>  measure.station.to_param}
        }.to change(Measure, :count).by(-1)
      end

      it "redirects to the measure list" do
        delete :destroy, {:id => measure.to_param, :station_id =>  measure.station.to_param}
        expect(response).to redirect_to(measures_url)
      end
    end
  end
end