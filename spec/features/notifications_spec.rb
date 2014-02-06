require 'spec_helper'

feature "Notifications", %{
  The app should be able to notify users of events with in app notifications.
} do

  let(:user) { create(:user) }
  let(:note) { create(:notification, user: user) }

  context "when I receive a notification" do

    before :each do
      note
      sign_in! user
    end

    scenario "when I click inbox page should show notification" do
      click_link "Inbox(1)", href: notifications_path
      expect(page).to have_content note.message
    end

    scenario "when I am at any page there should be a flash message" do
      visit root_path
      click_link "You have 1 unread notification."
      expect(page).to have_content note.message
    end

  end
end