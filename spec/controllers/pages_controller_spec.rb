require 'spec_helper'

describe PagesController do

  before :each do
    sign_out :user
  end

  describe "GET 'home'" do
    it "returns http success" do
      get :home
      expect(response).to be_success
    end

    it "renders the home template" do
      get :home
      expect(response).to render_template :home
    end
  end

  describe "GET 'products'" do
    it "returns http success" do
      get :products
      expect(response).to be_success
    end

    it "renders the products template" do
      get :products
      expect(response).to render_template :products
    end
  end

end
