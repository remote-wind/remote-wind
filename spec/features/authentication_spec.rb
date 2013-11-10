require 'spec_helper'

feature 'authentication' do

  let (:user) { FactoryGirl.create(:user) }

  describe 'signup' do

    scenario 'when signing up with incomplete details' do
      sign_up_with :email => 'test@example.com'
      expect(page).to have_content "Password can't be blank"
    end

    scenario 'when signing up with complete details' do
      sign_up_with :email => 'test@example.com',
                   :password => "I_Like_Rainbows",
                   :password_confirmation => "I_Like_Rainbows"
      expect(current_path).to eq(root_path)
      expect(page).to have_content 'Welcome! You have signed up successfully.'
    end

  end

  describe 'login' do
    scenario 'when logging in with incomplete details' do
      sign_in_as user.email, nil
      expect(page).to have_content "Invalid email or password."
    end

    scenario 'when logging in with valid details' do
      sign_in_as user.email, user.password
      expect(page).to have_content "Signed in successfully."
      expect(page).to_not have_link "Log in"
      expect(page).to_not have_link "Sign up"
      expect(page).to have_link 'Log out'
      expect(current_path).to eq root_path
    end
  end

  describe 'logout' do
    scenario 'when logging out' do
      sign_in_as user.email, user.password
      click_link 'Log out'
      expect(page).to have_content 'Signed out successfully.'
    end
  end

  describe 'edit profile' do

    scenario "when not logged in" do
      visit edit_user_registration_path
      expect(page).to have_content 'You need to sign in or sign up before continuing.'
    end

    context 'when logged in' do
      before { sign_in_as user.email, user.password }

      scenario 'edit details' do
        click_link 'Edit profile'
        expect(current_path).to eq edit_user_registration_path
      end

      scenario 'try to edit details without current password' do
        visit edit_user_registration_path
        fill_in 'Email', :with => 'foo@bar.com'
        click_button 'Update'
        expect(page).to have_content "Current password can't be blank"
      end

      scenario 'try to edit details with wrong password' do
        visit edit_user_registration_path
        fill_in 'Email', :with => 'foo@bar.com'
        fill_in 'Current password', :with  => 'haxxor666'
        click_button 'Update'
        expect(page).to have_content "Current password is invalid"
      end

      scenario 'edit detatils with current password' do
        visit edit_user_registration_path
        fill_in 'Email', :with => 'foo@bar.com'
        fill_in 'Current password', :with  => user.password
        click_button 'Update'
        expect(page).to have_content "You updated your account successfully."
      end
    end
  end

  describe 'Cancel account' do
    context 'when logged in' do
      before { sign_in_as user.email, user.password }
      scenario 'remove account' do
        visit edit_user_registration_path
        click_button 'Cancel my account'
        expect(page).to have_content 'Bye! Your account was successfully cancelled. We hope to see you again soon.'
      end

      scenario 'when trying to log in after removing account' do
        visit edit_user_registration_path
        click_button 'Cancel my account'
        sign_in_as user.email, user.password
        expect(page).to have_content 'Invalid email or password.'
      end
    end
  end

end