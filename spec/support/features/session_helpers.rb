module Features
  module SessionHelpers

    def sign_up_with hash
      visit root_path
      click_link 'Sign up'
      fill_in 'Email', :with => hash[:email]
      fill_in 'Password', :with => hash[:password]
      fill_in 'Password confirmation', :with => hash[:password_confirmation]
      click_button 'Sign up'
    end

    def sign_in_as(email, password)
      visit new_user_session_path
      fill_in 'Email', :with => email
      fill_in 'Password', :with => password
      click_button 'Sign in'
    end

    def login (user = FactoryGirl.create(:user))
      login_as(user, :scope => :user)
    end
  end
end