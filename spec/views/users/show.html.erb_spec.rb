require 'spec_helper'

describe 'users/show.html.erb' do

  before :each do
    stub_user_for_view_test(create(:user))
    developer = Role.create(name: :developer)
    spammer = Role.create(name: :spammer)
    @user.add_role :spammer
    assign( :available_roles, [developer] )
  end

  subject do
    render
    rendered
  end

  it { should include @user.email }

  describe 'role management' do

    context 'when not an authorized' do
      it { should_not have_selector '#user_roles' }
    end

    context 'when an admin' do
      subject {
        @ability.can :manage, User
        render
        rendered
      }
      it { should have_content "Add role to #{@user.email}"}
      it { should have_selector '.add-role' }
      it { should have_selector('.add-role select', text: 'developer') }
      it { should_not have_selector('.add-role select', text: 'spammer') }
      it { should have_selector('.remove-role select', text: 'spammer') }
      it { should_not have_selector('.remove-role select', text: 'developer') }

    end
  end

  describe 'providers' do
    before :each do

    end

  end

end
