require "spec_helper"

describe MeasuresController do
  describe "routing" do

    it "routes to #show" do
      get("/measures/1").should route_to("measures#show", :id => "1")
    end

    it "routes to #create" do
      post("/stations/1/measures").should route_to("measures#create", :station_id => "1")
    end

    it "routes to #create" do
      post("/measures").should route_to("measures#create")
    end

    it "routes to #destroy" do
      delete("/measures/1").should route_to("measures#destroy", :id => "1")
    end

    it "routes to measures#index" do
      get("/measures").should route_to("measures#index")
    end

    it "routes to measures#station_index" do
      get("/stations/1/measures").should route_to("measures#station_index", :station_id => "1")
    end

  end
end
