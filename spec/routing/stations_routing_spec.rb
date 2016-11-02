require 'rails_helper'

describe StationsController, type: :routing do
  describe "routing" do

    it "routes to #find" do
      expect(get("/stations/find/1")).to route_to("stations#find", hw_id: "1")
    end

  end
end
