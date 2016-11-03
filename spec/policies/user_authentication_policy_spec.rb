require 'rails_helper'

RSpec.describe UserAuthenticationPolicy do

  let(:user) { User.new }

  subject { described_class }

  permissions ".scope" do
    let(:user) { create(:user) }
    before { user.authentications.create(attributes_for(:user_authentication)) }
    subject { policy_scope(user).resolve }
    it { should eq UserAuthentication.where(user: user) }
  end

  permissions :show? do
    it { should_not permit(User.new, UserAuthentication.new) }
    it { should permit(user, UserAuthentication.new(user: user)) }
  end

  permissions :create? do
    it { should_not permit(User.new, UserAuthentication) }
  end

  permissions :update? do
    it { should_not permit(User.new, UserAuthentication.new) }
    it { should permit(user, UserAuthentication.new(user: user)) }
  end

  permissions :destroy? do
    it { should_not permit(User.new, UserAuthentication.new) }
    it { should permit(user, UserAuthentication.new(user: user)) }
  end
end
