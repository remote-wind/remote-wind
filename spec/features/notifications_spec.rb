require 'spec_helper'

feature "Notifications", %{
  The app should be able to notify users of events with in app notifications.
} do

  let(:user) { create(:user) }
  let(:note) { create(:notification, user: user) }

  context "when user receives a notification" do

    before :each do
      note
      sign_in! user
    end

    scenario "when I click inbox page should show notification" do
      click_link "Inbox", href: notifications_path
      expect(page).to have_content note.message
    end

  end
end