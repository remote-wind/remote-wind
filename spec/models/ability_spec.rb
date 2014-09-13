require 'spec_helper'
require 'cancan/matchers'

describe Ability do

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

    it { should be_able_to(:crud, auth) }
    it { should_not be_able_to(:crud, build_stubbed(:user_authentication, user: build_stubbed(:user))) }
    it { should be_able_to(:read, Station) }
    it { should be_able_to(:find, Station) }
    it { should be_able_to(:read, Observation) }
    it { should be_able_to(:create, Observation) }
    it { should be_able_to(:read, notification) }
    it { should be_able_to(:destroy, notification) }
  end

  context "an admin" do
    before do
      User.any_instance.stub(:has_role?).with(:admin).and_return(true)
    end
    it { should be_able_to(:manage, User) }
    it { should be_able_to(:manage, UserAuthentication) }
    it { should be_able_to(:manage, Station) }
  end
end