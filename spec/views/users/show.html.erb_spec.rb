require 'spec_helper'

describe "users/show.html.erb" do

  let!(:user) { create :user }

  subject do
    assign(:user, user)
    render
    rendered
  end

  it { should include user.email }
  it { should include user.created_at.to_s }
end
