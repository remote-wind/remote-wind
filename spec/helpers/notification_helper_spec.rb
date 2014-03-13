require 'spec_helper'

describe NotificationsHelper do

  let(:user) { build_stubbed(:user) }

  describe "#notification_classes" do

    let(:note) { create(:notification, event: 'test-event', level: :warning, read: false) }


    subject { notification_classes(note) }

    it { should include 'notification' }
    it { should include 'test-event' }
    it { should include 'warning' }
    it { should include 'unread' }

    context "when note has been read" do
      before (:each) { note.read = true}
      subject { notification_classes(note) }
      it { should include 'read' }
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

      subject { link_to_mark_all_as_read(user, nil) }

      it { should have_link "Mark all as read", href: user_notifications_path(user) }
      it { should have_css ".disabled[disabled]" }

    end

  end
end