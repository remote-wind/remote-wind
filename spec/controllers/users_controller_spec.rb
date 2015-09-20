require 'spec_helper'

describe UsersController, :type => :controller do

  let(:user) { create(:user) }

  before { sign_in user }

  subject { response }

  describe "GET 'show'" do
    before { get :show, id: user.to_param}
    it { is_expected.to have_http_status :success }
    it { is_expected.to render_template :show }
    it "finds the correct user" do
      expect(assigns(:user)).to eq user
    end
  end

  describe "GET 'index'" do
    before {  get 'index' }
      it { is_expected.to have_http_status :success }
      it { is_expected.to render_template :index }
  end
end