require 'spec_helper'

describe Users::OmniauthCallbacksController, type: :controller do

  before :each do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    AuthenticationProvider.create(name: 'facebook')
  end

  describe "GET facebook"  do

    let(:valid_auth_response) {
      OmniAuth.config.mock_auth[:facebook] = {
          provider: 'facebook',
          uid: '123545',
          info: {
              email: 'test@example.com',
              image: "http://example.com/image.jpg"
          },
          credentials: {
              token: 'facebook token',
              expires_at: Time.now + 1000
          }
      }
    }

    let(:invalid_auth_response) {
      OmniAuth.config.logger = Logger.new("/dev/null")
      response = OmniAuth.config.mock_auth[:facebook] = :invalid
      response
    }

    xit "assigns image to user" do
      # allow(@controller).to receive(:user_signed_in?).and_return nil
      # allow(@controller).to receive(:sign_in_and_redirect).and_return nil
      # allow(@controller).to receive(:current_user).and_return(User.new)
      # request.env["omniauth.auth"] = valid_auth_response
      # get :facebook
      # expect(assigns(:current_user).image).to eq "http://example.com/image.jpg"
    end
  end
end
