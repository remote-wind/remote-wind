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
end