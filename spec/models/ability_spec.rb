require 'spec_helper'
require 'cancan/matchers'

# @see https://github.com/CanCanCommunity/cancancan/wiki/Testing-Abilities
describe Ability, type: :model do

  subject { Ability.new(user) }

  let(:user) { build_stubbed(:user) }
  let(:auth) { build_stubbed(:user_authentication, user: user) }
  let(:notification) { build_stubbed(:notification, user: user) }

  context "a guest user" do
    it "should be able to manage self" do
      expect(subject).to be_able_to(:crud, user)
    end
    it "should not be able to manage others" do
      expect(subject).to_not be_able_to(:manage, User)
    end
    it { is_expected.to be_able_to(:crud, auth) }
    it { is_expected.not_to be_able_to(:crud, build_stubbed(:user_authentication, user: build_stubbed(:user))) }
    it { is_expected.to be_able_to(:read, Station) }
    it { is_expected.to be_able_to(:find, Station) }
    it { is_expected.to be_able_to(:read, Observation) }
    it { is_expected.to be_able_to(:create, Observation) }
    it { is_expected.to be_able_to(:read, notification) }
    it { is_expected.to be_able_to(:destroy, notification) }
  end

  context "an admin" do
    before do
      allow_any_instance_of(User).to receive(:has_role?).with(:admin).and_return(true)
    end
    it { is_expected.to be_able_to(:manage, User) }
    it { is_expected.to be_able_to(:manage, UserAuthentication) }
    it { is_expected.to be_able_to(:manage, Station) }
  end
end
