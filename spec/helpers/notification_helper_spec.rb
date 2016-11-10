require 'rails_helper'

describe NotificationsHelper, type: :helper do

  let(:user) { build_stubbed(:user) }

  describe "#notification_classes" do

    let(:note) { create(:notification, event: 'test-event', level: :warning, read: false) }


    subject { notification_classes(note) }

    it { is_expected.to include 'notification' }
    it { is_expected.to include 'test-event' }
    it { is_expected.to include 'warning' }
    it { is_expected.to include 'unread' }

    context "when note has been read" do
      before (:each) { note.read = true}
      subject { notification_classes(note) }
      it { is_expected.to include 'read' }
    end

  end

  describe "#link_to_notifications" do

    it "should accept nil" do
      expect(link_to_notifications(user, nil)).to eq link_to "Inbox", user_notifications_path(user)
    end

    it "should not append 0" do
      expect(link_to_notifications(user, 0)).to eq link_to "Inbox", user_notifications_path(user)
    end

    it "should append count within parens" do
      expect(link_to_notifications(user, 5)).to eq link_to "Inbox(5)", user_notifications_path(user)
    end

  end

  describe "#link_to_mark_all_as_read" do

    context "when called with nil number of notifications" do
      subject { link_to_mark_all_as_read(user) }
      it { is_expected.to have_link "Mark all as read", href: user_notifications_path(user) }
    end

  end
end