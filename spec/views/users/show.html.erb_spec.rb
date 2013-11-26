require 'spec_helper'

describe "users/show.html.erb" do

  before(:each) do
    stub_user_for_view_test(create(:user))
  end

  subject do
    render
    rendered
  end

  it { should include @user.email }
  it { should include @user.created_at.to_s }

  describe "role  management" do

    context "when not an authorized" do
      it { should_not have_selector "#user_roles" }
    end

    context "when an admin" do
      subject {
        @ability.can :manage, User
        render
        rendered
      }
      it { should have_content "Add role to #{@user.email}"}
      it { should have_selector "#user_roles" }
    end
  end
end
