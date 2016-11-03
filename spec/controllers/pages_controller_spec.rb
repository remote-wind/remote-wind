require 'rails_helper'

RSpec.describe PagesController do

  before { logout :user }
  subject { response }

  describe "GET 'home'" do
    before { get :home }
    it { should have_http_status :success }
    it { should render_template :home }
  end

  describe "GET 'products'" do
    before { get :products }
    it { should have_http_status :success }
    it { should render_template :products }
  end
end
