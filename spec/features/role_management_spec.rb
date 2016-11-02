require 'rails_helper'

feature "roles" do

  let!(:admin) { create(:admin) }
  let!(:user) { create(:user) }

  before { sign_in! admin }

  context "As an admin" do
    scenario "I should be able to add roles to users" do
      visit edit_user_path(user)
      check 'admin'
      click_button 'Update User'
      expect(user.reload.has_role?(:admin)).to be_truthy
    end
    scenario "I should be able to revoke a role" do
      user.add_role(:admin)
      visit edit_user_path(user)
      uncheck 'admin'
      click_button 'Update User'
      expect(user.reload.has_role?(:admin)).to be_falsy
    end
  end
end