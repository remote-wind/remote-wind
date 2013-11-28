require 'spec_helper'

describe RolesController do


  describe "POST users/:user_id/roles" do
    context "when not authorized" do
      let(:user){ create(:user) }
      before { sign_in user }
      let!(:wizard) { Role.create(:name => :wizard) }

      it "does not create role" do
        post :create, { :user_id =>  user.to_param, :user => { :roles => wizard.id }}
        expect(user.has_role? :admin).to be_false
      end

      it "denies access" do
        bypass_rescue
        expect do
          post :create, { :user_id =>  user.to_param, :user => { :roles => wizard.id }}
        end.to raise_error CanCan::AccessDenied
      end
    end

    context "when a user who can manage roles" do
      let(:user) { create(:user) }
      let!(:wizard) { Role.create(:name => :wizard) }
      let!(:admin) { sign_in create(:admin) }

      it "adds role to user" do
        post :create, { :user_id =>  user.to_param, :user => { :roles => wizard.id }}
        expect(user.has_role? :wizard).to be_true
      end
    end
  end

  describe "DELETE users/:user_id/roles" do
    context "when not authorized" do
      let(:user){ create(:user) }
      let!(:wizard) { Role.create(:name => :wizard) }

      before {
        sign_in user
        user.add_role(:wizard)
      }

      it "does not remove role" do
        delete :destroy, { user_id:  user.to_param, id: wizard.to_param }
        expect(user.has_role? :wizard).to be_true
      end

      it "denies access" do
        bypass_rescue
        expect do
          delete :destroy, { user_id:  user.to_param, user: { roles: wizard.to_param }}
        end.to raise_error CanCan::AccessDenied
      end
    end

    context "when a user who can manage roles" do

      let(:user) { create(:user) }
      let!(:admin) { sign_in create(:admin) }
      let!(:wizard) { Role.create(:name => :wizard) }

      before { user.add_role(:wizard) }

      it "revokes a role" do
        delete :destroy, { user_id:  user.to_param, user: { roles: wizard.to_param }}
        expect(user.has_role? :wizard).to be_false
      end

      it "redirects back to user" do
        delete :destroy, { user_id:  user.to_param, user: { roles: wizard.to_param }}
        expect(response).to redirect_to user_path user
      end
    end
  end
end
