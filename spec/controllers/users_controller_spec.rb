require 'spec_helper'

describe UsersController do

  let(:user) { FactoryGirl.create(:user) }

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
    it "returns http success" do
      get 'index'
      response.should be_success
    end

    it "should assign users" do
      get 'index'
      expect(assigns(:users)) == [user]
    end
  end

end
