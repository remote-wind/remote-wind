require 'spec_helper'

feature 'authorization' do



  context 'when logged in as a regular user' do
    let!(:user) { create(:user) }
    let!(:user2) { create(:user, :email => "#{rand(1000)}@example.com" ) }

    before { sign_in_as user.email, user.password }

    scenario 'attempts to edit other user' do
      visit edit_user_registration_path(user2)
    end
  end

  context 'when logged in as an admin' do

    let!(:admin) { create(:admin) }
    before { sign_in_as admin.email, admin.password }
  end

end