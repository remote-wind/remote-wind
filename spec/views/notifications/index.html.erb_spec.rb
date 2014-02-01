require 'spec_helper'

describe "notifications/index" do

  let(:notifications) {
    notes = [*1..3].map! { build_stubbed(:notification, created_at: Time.new(2000) + 1.hour) }
    notes.push ( build_stubbed(:notification, read: true, created_at: Time.new(2000)) )
    notes
  }

  before do
    assign(:notifications, notifications)
    render
  end

  subject { rendered }

  it { should have_selector '.notification', exact: notifications.size }
  it { should have_selector ".#{notifications.first.event}" }
  it { should have_selector '.notification:first .message', text: notifications.first.message }
  it { should have_selector "#notification-#{notifications.first.id}" }
  it { should have_selector '.notification.unread', exact: 3 }
  it { should have_selector '.notification.read' }
  it { should have_selector '.notification:first .created-at', text: "2000-01-01 00:00" }

end