require 'spec_helper'

describe RolesController, :type => :controller do

  let(:user){ create(:user) }
  let(:role) { Role.create(name: :wizard) }

  describe "POST users/:user_id/roles" do


    let(:action) {  post :create, { user_id:  user.to_param, user: { roles: role }} }

    context "when not authorized" do
      before { sign_in user }

      it "does not create role" do
        expect(user.has_role? :admin).to be_falsey
      end

      it "denies access" do
        bypass_rescue
        expect { action }.to raise_error CanCan::AccessDenied
      end
    end

    context "when a user who can manage roles" do
      before { sign_in create(:admin) }
      it "adds role to user" do
        action
        expect(user.has_role?(:wizard)).to be_truthy
      end
    end
  end

  describe "DELETE users/:user_id/roles" do

    let(:action) { delete :destroy, { user_id:  user, user: { roles: role }} }

    context "when not authorized" do

      before {
        sign_in user
        user.add_role(:wizard)
      }

      it "does not remove role" do
        action
        expect(user.has_role? :wizard).to be_truthy
      end

      it "denies access" do
        bypass_rescue
        expect do
          action
        end.to raise_error CanCan::AccessDenied
      end
    end

    context "when a user who can manage roles" do

      before do
        user.add_role(:wizard)
        sign_in create(:admin)
        action
      end

      it "revokes a role" do
        expect(user.has_role? :wizard).to be_falsey
      end

      it "redirects back to user" do
        expect(response).to redirect_to user_path user
      end
    end
  end
end
