require 'spec_helper'

describe UsersController do


  let!(:user) do
    user = FactoryGirl.create(:user)
    sign_in user
    user
  end


  describe "GET 'show'" do

    it "should be successful" do
      get :show, :id => user.id
      expect(response).to be_success
    end

    it "should find the right user" do
      get :show, :id => user.id
      expect(assigns(:user)) == @user
    end
  end

  describe "GET 'index'" do

    context "when not authorized" do
      it "should be denied" do
        bypass_rescue
        expect { get 'index' }.to raise_error(CanCan::AccessDenied)
      end
    end

    context "when authorized" do

      before do
        sign_in create(:admin)
      end

      it "should be successful" do
        get 'index'
        expect(response).to be_success
      end

    end

  end
end
