require 'spec_helper'

describe ApplicationController do

  describe "authentication failure" do

    before do
      @user = User.new
    end

    subject { get :honeypot }

    it "redirects to login page if there is no current user" do
      @controller.stub(:current_user).and_return(false)
      expect(subject).to redirect_to new_user_session_path
    end

    it "redirects to root page if user is logged in" do
      @controller.stub(:current_user).and_return(true)
      expect(subject).to redirect_to root_path
    end
  end
end