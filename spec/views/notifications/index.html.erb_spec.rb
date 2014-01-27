require 'spec_helper'

describe "notifications/index" do

  let(:notifications) { [*1..5].map! { build_stubbed :notification }}

  before do
    assign(:notifications, notifications)
    render
  end

  subject { rendered }

  it { should have_selector '.notification', exact: notifications.length }
  it { should have_selector ".#{notifications.first.key}" }
  it { should have_selector '.notification:first .message', text: notifications.first.message }
  it { should have_selector '.notification:first .subject', text: notifications.first.subject }

end