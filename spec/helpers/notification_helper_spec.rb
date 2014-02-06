require 'spec_helper'

describe NotificationsHelper do

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
      expect(link_to_notifications(nil)).to eq link_to "Inbox", notifications_path
    end

    it "should not append 0" do
      expect(link_to_notifications(0)).to eq link_to "Inbox", notifications_path
    end

    it "should append count within parens" do
      expect(link_to_notifications(5)).to eq link_to "Inbox(5)", notifications_path
    end

  end

end