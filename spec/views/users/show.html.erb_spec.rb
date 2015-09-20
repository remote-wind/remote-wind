require 'spec_helper'

describe 'users/show.html.erb', :type => :view do


  let(:user) { create(:user) }

  before :each do
    sign_out :user
    stub_user_for_view_test(user)
    @user.add_role Role.create(name: :spammer).name
    assign( :available_roles, [Role.create(name: :developer)] )
  end

  subject do
    render
    rendered
  end

  it { is_expected.to include user.nickname }

  describe 'role management' do

    context 'when not an authorized' do
      it { is_expected.not_to have_selector '#user_roles' }
    end

    context 'when an admin' do
      before { @ability.can :manage, User }
      it { is_expected.to have_content "Add role to #{ user.nickname }"}
      it { is_expected.to have_selector '.add-role' }
      it { is_expected.to have_selector('.add-role select', text: 'developer') }
      it { is_expected.not_to have_selector('.add-role select', text: 'spammer') }
      it { is_expected.to have_content "Remove role from #{ user.nickname }"}
      it { is_expected.to have_selector('.remove-role select', text: 'spammer') }
      it { is_expected.not_to have_selector('.remove-role select', text: 'developer') }
    end
  end

end
