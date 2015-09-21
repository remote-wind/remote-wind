require 'spec_helper'

describe 'users/show.html.erb', type: :view do


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
      it { is_expected.to have_link "Edit user" }
    end
  end

end
