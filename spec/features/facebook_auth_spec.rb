require 'spec_helper'
feature 'Facebook Authentiation' do

  background do
    visit root_path
    AuthenticationProvider.create(name: 'facebook')
  end

  let(:valid_auth_response) {
    OmniAuth.config.mock_auth[:facebook] = {
      provider: 'facebook',
      uid: '123545',
      info: {
          email: 'test@example.com'
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

  scenario 'I click signup via facebook and approve app permissions' do
    visit new_user_registration_path
    valid_auth_response
    click_link "Sign in with Facebook"
    expect(current_path).to eq root_path
    expect(page).to have_content  "Welcome test@example.com"
  end

  scenario 'I click signup via facebook and do not approve app permissions' do
    visit new_user_registration_path
    invalid_auth_response
    click_link "Sign in with Facebook"
    expect(page).to have_content "Could not authenticate you from Facebook"
  end

  context "when user is registered" do
    before do
      visit new_user_registration_path
      valid_auth_response
      click_link "Sign in with Facebook"
      sign_out_via_capybara
    end

    scenario "I click login with facebook" do
      visit root_path
      click_link "Log in"
      valid_auth_response
      click_link "Sign in with Facebook"
      expect(page).to have_content "Welcome back test@example.com!"
    end

    scenario "I click login with facebook and the auth response is invalid" do
      visit root_path
      click_link "Log in"
      invalid_auth_response
      click_link "Sign in with Facebook"
      expect(page).to have_content "Could not authenticate you from Facebook"
    end
  end

  context "when a previously registered user adds FB authentication" do
    let!(:user) { create(:user, :email => 'test@example.com') }
    before :each do
      visit new_user_registration_path
      valid_auth_response
    end

    it "adds auth indentity to previous user" do
      expect{
        click_link "Sign in with Facebook"
      }.to change(user.authentications, :count).by(+1)
      expect(User.count).to eq 1
    end
  end
end