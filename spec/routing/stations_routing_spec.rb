require "spec_helper"

describe StationsController do
  describe "routing" do

    it "routes to #find" do
      get("/stations/find/1").should route_to("stations#find", :hw_id => "1")
    end

  end
end
