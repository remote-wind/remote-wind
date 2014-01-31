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

    scenario "when I click inbox" do
      pending "BUG: why is this redirecting?"
      visit notifications_path
      expect(current_path).to eq "/notifications"
    end
  end
end