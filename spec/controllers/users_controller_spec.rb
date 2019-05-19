require 'rails_helper'

describe UsersController, type: :controller do

  let(:user) { create(:user) }
  subject { response }

  context "an unprivileged user" do
    before do
      bypass_rescue
      sign_in create(:user)
    end
    describe "GET 'show'" do
      before {  get :show, params: { id: user } }
      it { should have_http_status :success }
      it { should render_template :show }
      it "finds the correct user" do
        expect(assigns(:user)).to eq user
      end
    end
    describe "GET 'index'" do
      before { get :index }
      it { should have_http_status :success }
      it { should render_template :index }
    end
    describe "GET 'edit'" do
      it "denies access" do
        expect {
          get :edit, params: { id: create(:user) }
        }.to raise_error Pundit::NotAuthorizedError
      end
    end
    describe "PATCH 'update'" do
      it "denies access" do
        expect {
          patch :update, params: { id: user, user: { email: 'test@example.com' } }
        }.to raise_error Pundit::NotAuthorizedError
      end
    end
    describe "DESTROY 'delete'" do
      it "denies access" do
        expect {
          delete :destroy, params: { id: user }
        }.to raise_error Pundit::NotAuthorizedError
      end
    end
  end

  context "an admin" do
    before { sign_in create(:admin) }
    describe "GET 'edit'" do
      before { get :edit, params: { id: create(:user) } }
      it { should render_template :edit }
      it { should be_successful }
    end
    describe "PATCH 'update'" do
      context "with valid attributes" do
        before do
          patch :update, params: { id: user, user: { email: 'test@example.com' } }
        end
        it "updates the user" do
          expect(user.reload.unconfirmed_email).to eq 'test@example.com'
        end
        it { should redirect_to user_path(user) }
      end
      context "with invalid attributes" do
        before do
          patch :update, params: { id: user, user: { email: '' } }
        end
        it { should render_template :edit }
      end

      describe "nested roles" do
        let!(:role) { Role.create(name: :foo) }
        it "adds a role to user" do
          patch :update, params: {
            id: user, user: { role_ids: [ role.id ] }
          }
          expect(user.has_role?(role.name)).to be_truthy
        end
        it "removes a role from user" do
          r = Role.create(name: 'bar')
          user.add_role(role.name)
          patch :update, params: {
            id: user,
            user: { role_ids: [nil] } # We need nil as the params are compacted
          }
          user.reload
          expect(user.has_role?(role.name)).to be_falsy
        end
      end

    end
    describe "DELETE 'destroy'" do
      let!(:user) { create(:user) }
      it "destroys the user" do
        expect {
          delete :destroy, params: { id: user }
        }.to change(User, :count).by(-1)
      end
    end
  end
end
