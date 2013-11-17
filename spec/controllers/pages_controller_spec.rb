require 'spec_helper'

describe PagesController do

  describe "GET 'home'" do
    it "returns http success" do
      get 'home'
      response.should be_success
    end
  end

  describe "GET 'products'" do
    it "returns http success" do
      get 'products'
      response.should be_success
    end
  end

end
