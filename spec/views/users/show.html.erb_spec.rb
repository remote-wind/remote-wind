require 'spec_helper'

describe 'users/show.html.erb' do


  let(:u) { create(:user) }

  before :each do
    sign_out :user
    stub_user_for_view_test(u)
    @user.add_role Role.create(name: :spammer).name
    assign( :available_roles, [Role.create(name: :developer)] )

  end

  subject do
    render
    rendered
  end

  it { should include u.nickname }

  describe 'role management' do

    context 'when not an authorized' do
      it { should_not have_selector '#user_roles' }
    end

    context 'when an admin' do
      before { @ability.can :manage, User }
      it { should have_content "Add role to j_random_user"}
      it { should have_selector '.add-role' }
      it { should have_selector('.add-role select', text: 'developer') }
      it { should_not have_selector('.add-role select', text: 'spammer') }
      it { should have_content "Remove role from j_random_user"}
      it { should have_selector('.remove-role select', text: 'spammer') }
      it { should_not have_selector('.remove-role select', text: 'developer') }
    end
  end

end
