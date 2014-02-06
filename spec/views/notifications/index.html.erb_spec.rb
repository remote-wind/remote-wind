require 'spec_helper'

describe "notifications/index" do

  let(:notifications) {
    WillPaginate::Collection.create(1, 10, 50) do |pager|
      pager.replace([*1..50].map! { |i| build_stubbed(:notification, created_at: Time.new(2000) + i.hour) })
    end
  }

  before do
    notifications.last.read = true
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
  it { should have_selector '.pagination' }

end