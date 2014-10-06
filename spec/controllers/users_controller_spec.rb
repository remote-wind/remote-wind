require 'spec_helper'

describe UsersController, :type => :controller do

  let!(:user) do
    user = FactoryGirl.create(:user)
    sign_in user
    user
  end

  describe "GET 'show'" do
    before { get :show, id: user.to_param}
    subject { response }

    it { is_expected.to be_successful }
    it { is_expected.to render_template :show }

    it "should find the right user" do
      expect(assigns(:user).id) == user.id
    end
  end

  describe "GET 'index'" do
    before {  get 'index' }
    subject { response }

      it { is_expected.to be_successful }
      it { is_expected.to render_template :index }
  end
end