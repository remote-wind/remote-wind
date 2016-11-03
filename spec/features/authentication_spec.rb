require 'rails_helper'

feature 'Authentication' do

  let (:user) { FactoryGirl.create(:user) }

  describe 'Signup' do
    scenario 'without all required fields, should display errors' do
      sign_up_with email: nil,
                   password: nil,
                   password_confirmation: nil

      expect(page).to have_content "Password can't be blank"
      expect(page).to have_content "Email can't be blank"
    end
    scenario 'with passwords that don´t match, should display error' do
      sign_up_with password: 'foobarbaz',
                   password_confirmation: 'FOOBARBAZ'

      expect(page).to have_content "Password confirmation doesn't match Password"
    end
    scenario 'with complete details, should create account' do
      sign_up_with email: 'test@example.com',
                   password: "I_Like_Rainbows",
                   password_confirmation: "I_Like_Rainbows"

      expect(current_path).to eq(root_path)
      expect(page).to have_content(
        'A message with a confirmation link has been sent to your email address. ' +
        'Please open the link to activate your account.'
      )
    end
  end

  describe 'Email confirmation' do
    scenario "when I click link in confirmation mail, should confirm email" do
      user = create(:unconfirmed_user)
      visit '/signin'
      click_link "Didn't receive confirm instructions?"
      fill_in "Email", with: user.email
      click_button 'Resend confirmation instructions'
      mail = Capybara.string(ActionMailer::Base.deliveries.last.body.to_s)
      visit mail.find('a', text: "Confirm my account")[:href]
      expect(user.reload.confirmed_at).to_not be_nil
      expect(page).to have_content "Your account was successfully confirmed."
    end
  end

  describe 'Login' do
    scenario 'when I enter incomplete details; should display the errors' do
      sign_in_as user.email, nil
      expect(page).to have_content "Invalid email or password."
    end
    scenario 'with valid details, should sign me in' do
      sign_in_as user.email, user.password
      expect(page).to have_content "Signed in successfully."
      expect(page).to_not have_link "Log in"
      expect(page).to_not have_link "Sign up"
      expect(page).to have_link 'Log out'
      expect(current_path).to eq root_path
    end
  end

  describe 'Logout' do
    scenario 'when I click log out button; should sign me out' do
      sign_in_as user.email, user.password
      click_link 'Log out'
      expect(page).to have_content 'Signed out successfully.'
    end
  end

  describe 'Edit profile' do
    scenario "when I am not logged in; should deny access" do
      visit edit_user_registration_path
      expect(page).to have_content 'You need to sign in or sign up before continuing.'
    end
    context 'when logged in' do
      before { sign_in_as user.email, user.password }
      scenario 'when I edit my details; should update account' do
        click_link 'Edit profile'
        fill_in 'Email', with: 'foo@bar.com'
        click_button 'Update'
        expect(page).to have_content "Your profile has been updated."
        expect(user.reload.unconfirmed_email).to eq 'foo@bar.com'
      end
    end
  end

  describe 'Cancel account' do
    before { sign_in_as user.email, user.password }
    scenario 'when I click "Cancel my account"; should remove my account' do
      visit edit_user_registration_path
      click_link 'Cancel my account'
      expect(page).to have_content 'Bye! Your account was successfully cancelled. We hope to see you again soon.'
      sign_in_as user.email, user.password
      expect(page).to have_content 'Invalid email or password.'
    end
  end
end
