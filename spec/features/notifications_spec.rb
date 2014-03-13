require 'spec_helper'

feature "Notifications", %{
  The app should be able to notify users of events with in app notifications.
} do

  let(:user) { create(:user) }
  let(:note) { create(:notification, user: user) }
  let(:notifications_path) {  user_notifications_path(user_id: user.to_param)  }

  context "when I receive a notification" do

    before :each do
      note
      sign_in! user
    end

    scenario "when I click inbox page should show notification" do
      click_link "Inbox(1)", href: notifications_path
      expect(page).to have_content note.message
    end

    scenario "when I click inbox page should show notification" do
      click_link "Inbox(1)", href: notifications_path
      expect(page).to have_title "Inbox(1) | Remote Wind"
    end

    scenario "when I am at any page there should be a flash message" do
      visit root_path
      click_link "You have 1 unread notification."
      expect(page).to have_content note.message
    end

  end

  describe "marking all notifications as read" do

    before :each do
      sign_in! user
      visit notifications_path
      note
    end

    scenario "when I click mark all as read" do
      click_link "Mark all as read"
      expect(note.reload.read).to be_true
    end

  end

  describe "deleting a notification" do

    before :each do
      sign_in! user
      note
    end

    scenario "when I click delete" do
      visit notifications_path
      expect {
        click_link "delete"
      }.to change(Notification, :count).by(-1)
    end

  end

  describe "deleting all notifications" do

    before :each do
      sign_in! user
      note
    end

    scenario "when I click delete all" do
      visit notifications_path

      expect {
        within('#delete-notifications-form') do
          fill_in :time, with: 0
          click_button "Delete", "#delete-notifications-form"
        end
      }.to change(Notification, :count).by(-1)
    end


  end


end