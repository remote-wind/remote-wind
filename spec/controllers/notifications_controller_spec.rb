require 'spec_helper'

describe NotificationsController do

  before :each do
    sign_out :user
  end

  describe "GET 'index'" do

    let(:note) { create(:notification) }

    it "assigns current user as @user" do
      user = create(:user)
      sign_in user
      get :index
      expect(assigns(:user).id).to eq user.id
    end

    it "does not allow user notifications which are not adressed to her" do
      sign_in create(:user)
      private = create(:notification, user_id: 9999)
      get :index
      expect(assigns(:notifications)).to_not include private
    end

    it "allows user to see notifications addressed to her" do
      user = create(:user)
      sign_in user
      private = create(:notification, user_id: user.id)
      get :index
      expect(assigns(:notifications)).to include private
    end

  end
end