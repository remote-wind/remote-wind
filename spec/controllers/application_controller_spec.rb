require 'spec_helper'

describe ApplicationController do

  # Sanity check to make sure enviroment is set up
  describe "enviromental variables"  do

    it "should have email" do
      expect(ENV['REMOTE_WIND_EMAIL'].blank?).to be_false
    end


  end
end