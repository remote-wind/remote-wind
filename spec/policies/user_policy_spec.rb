require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  permissions ".scope" do
    it "includes all the users" do
      expect(policy_scope(User.new).resolve).to eq User.all
    end
  end

  permissions :show? do
    it "allows any user" do
      expect(subject).to permit(User.new, User.new)
    end
  end

  permissions :create? do
    it "not permitted since it is handled by Devise anyways" do
      expect(subject).to_not permit(User.new, User.new)
    end
  end

  permissions :update? do
    it "does not permit a user to edit other users" do
      expect(subject).to_not permit(User.new, User.new)
    end
    it "allows a user to edit their own record" do
      expect(subject).to permit(admin, user)
    end
    it "allows admins to edit others" do
      expect(subject).to permit(admin, User.new)
    end
  end

  permissions :destroy? do
    it "does not permit a user to destroy their own account" do
      expect(subject).to_not permit(User.new, User.new)
    end
    it "allows admins to destroy users" do
      expect(subject).to permit(admin, User.new)
    end
  end
end
