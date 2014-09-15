require 'spec_helper'

describe "notifications/index" do

  let(:user) { build_stubbed(:user) }
  let(:notifications) do
    WillPaginate::Collection.create(1, 10, 50) do |pager|
      pager.replace([*1..50].map! { |i| build_stubbed(:notification, created_at: Time.new(2000) + i.hour, user: user) })
    end
  end


  let(:rendered_view) do
    notifications.last.read = true
    assign(:notifications, notifications)
    assign(:user, user)
    render
    rendered
  end

  it "should have the right contents" do
    expect(rendered_view).to have_selector '.notification', exact: notifications.size
    expect(rendered_view).to have_selector ".#{notifications.first.event}"
    expect(rendered_view).to have_selector '.notification .message', text: notifications.first.message
    expect(rendered_view).to have_selector "#notification-#{notifications.first.id}"
    expect(rendered_view).to have_selector '.notification.unread', exact: 3
    expect(rendered_view).to have_selector '.notification.read'
    expect(rendered_view).to have_selector '.pagination'
  end



end