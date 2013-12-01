require 'spec_helper'

describe ApplicationController do

  before :each do
    sign_out :user
  end

  describe "authentication failure" do

    subject { get :honeypot }

    it "redirects to login page if there is no current user" do
      expect(subject).to redirect_to new_user_session_path
    end

    it "redirects to root page if user is logged in" do
      sign_in create(:user)
      expect(subject).to redirect_to root_path
    end
  end

  describe ".get_all_stations" do

    let!(:station) { create(:station) }
    let!(:hidden_station) { create(:station, show: false) }

    context "when not authorized" do
      it "should return only visible stations" do
        expect(@controller.get_all_stations).to eq [station]
      end
    end


    context "when logged in as an admin" do
      before :each do
        sign_in create(:admin)
      end

      it "should return visible stations" do
        expect(@controller.get_all_stations).to include station
      end

      it "should return hidden stations" do
        expect(@controller.get_all_stations).to include hidden_station
      end
    end
  end
end