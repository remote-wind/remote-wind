module Features
  module SessionHelpers

    def sign_up_with hash
      visit new_user_registration_path
      fill_in 'Email', :with => hash[:email]
      fill_in 'user_password', :with => hash[:password]
      fill_in 'user_password_confirmation', :with => hash[:password_confirmation]
      click_button 'Sign up'
    end

    def sign_in_as(email, password)
      visit new_user_session_path
      fill_in 'Email', :with => email
      fill_in 'Password', :with => password
      click_button 'Sign in'
    end

    def sign_in!(user)
      sign_in_as(user.email, user.password)
      return user
    end

    def login (user = FactoryGirl.create(:user))
      login_as(user, :scope => :user)
    end

    # http://stackoverflow.com/questions/5018344
    def stub_user_for_view_test user = mock_model(User)
      @user = user
      assign(:user, @user)
      @ability = Object.new
      @ability.extend(CanCan::Ability)
      allow(controller).to receive(:current_ability) { @ability }
      assign(:ability, @ability)
    end

    def sign_out_via_capybara
      visit root_path
      click_link "Log out"
    end

  end
end