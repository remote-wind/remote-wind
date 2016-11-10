require 'rails_helper'

RSpec.describe NotificationPolicy do

  let(:user) { User.new }

  permissions ".scope" do
    let!(:user) { create(:user) }
    let!(:note) { create(:notification) }
    let!(:note2) { create(:notification, user: user) }
    subject { policy_scope(user).resolve }
    it { should eq user.notifications }
  end

  permissions :show? do
    it { should_not permit(User.new, Notification.new) }
    it { should permit(user, Notification.new(user: user)) }
  end

  permissions :create? do
    it { should_not permit(User.new, Notification) }
    it { should_not permit(user, Notification) }
    it { should_not permit(admin, Notification) }
  end

  permissions :update? do
    it { should_not permit(User.new, Notification.new) }
    it { should permit(user, Notification.new(user: user)) }
  end

  permissions :destroy? do
    it { should_not permit(User.new, Notification.new) }
    it { should permit(user, Notification.new(user: user)) }
  end
end
