require 'spec_helper'

describe MeasuresController do

  let(:measure) { create(:measure, :station => build_stubbed(:station) ) }
  let(:valid_attributes) {
    create(:station)
    attributes_for(:measure, :station_id => 1 )
  }

  describe "GET 'show'" do
    before do
      measure
    end

    it "returns http success" do
      get 'show', { id: 1 }
      response.should be_success
    end
  end

  describe "GET 'index'" do


    it "returns http success" do
      get 'index'
      response.should be_success
    end

    it "assigns measures" do
      measure
      get 'index'
      expect(assigns(:measures)).to eq [measure]
    end
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

  end

  describe "DELETE 'destroy'" do

    before do
      measure #lazy load measure
    end

    context "as unpriveleged user" do
      before { sign_in create(:user) }
      it "should not allow measures to be destoyed without authorization" do
        expect do
          delete :destroy, {:id => measure.to_param}
        end.to raise_error CanCan::AccessDenied
      end
    end

    context "as admin" do
      before { sign_in create(:admin) }

      it "destroys the requested measure" do
        expect {
          delete :destroy, {:id => measure.to_param}
        }.to change(Measure, :count).by(-1)
      end

      it "redirects to the measure list" do
        delete :destroy, {:id => measure.to_param}
        response.should redirect_to(measures_url)
      end
    end
  end
end
