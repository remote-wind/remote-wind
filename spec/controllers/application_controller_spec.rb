require 'spec_helper'

describe ApplicationController, :type => :controller do

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
end