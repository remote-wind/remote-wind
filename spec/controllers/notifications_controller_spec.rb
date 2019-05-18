require 'rails_helper'

describe NotificationsController, type: :controller do

  let(:user) { user = create(:user) }
  let(:note) { create(:notification, user: user) }
  let(:params) { { user_id: user } }

  def get_index(**kwargs)
    get :index, params: params.merge(kwargs)
  end

  subject { response }

  describe "GET 'index'" do

    before :each do
      sign_in user
    end

    it "should handle an empty set gracefully" do
      get_index( page: 4 )
      expect(response).to be_success
    end

    it "redirects if user is not logged in" do
      sign_out :user
      get_index
      expect(response).to redirect_to '/signin'
    end

    it "assigns current user as @user" do
      get_index
      expect(assigns(:user).id).to eq user.id
    end

    it "does not allow user notifications which are not adressed to her" do
      private = create(:notification, user: create(:user))
      get_index
      expect(assigns(:notifications)).to_not include private
    end

    it "allows user to see notifications addressed to her" do
      private = create(:notification, user: user)
      get_index
      expect(assigns(:notifications)).to include private
    end

    it "sets notifications as read after render" do
      create(:notification, user: user)
      get_index
      expect(assigns(:notifications).first.read).to be_truthy
    end

    # For some reason .last gives wrong number of arguments (given 1, expected 0)
    # I have no explaination why
    xit "sorts notifications in descending order" do
      create(:notification, user: user)
      note2 = create(:notification, user: user )
      note2.update_attribute(:created_at, 1.year.ago)
      get_index
      expect(assigns(:notifications).first.created_at).to be > assigns(:notifications).last.created_at
    end

    it "uses page parameter to paginate notifications" do
      expect_any_instance_of(ActiveRecord::Relation)
                    .to receive(:paginate)
                    .with(page: "4")
                    .and_return(Notification)
      #Notification
      get_index(page: 4)
    end

    it "flashes when user has unread notifications" do
      create(:notification, user: user)
      get_index
      expect(flash[:notice]).to include "You have 1 unread notification."
    end
  end

  describe "PATCH 'update_all'" do

    before(:each) { sign_in user }

    context "when user has no unread notifications" do
      before(:each) { patch :update_all, params: params }
      it { is_expected.to redirect_to notifications_url }
      it "should flash error" do
        expect(flash[:error]).to match /no unread notifications found/i
      end
    end

    context "when user has notifications" do

      before(:each) do
         note
         patch :update_all, params: params
      end

      it { is_expected.to redirect_to notifications_url }

      it "should redirect to notifications" do
        expect(flash[:success]).to match /all notifications have been marked as read/i
      end

      it "set all notifications as read" do
        expect(note.reload.read).to be_truthy
      end

    end

    it "should not change notifications that do not belong to current user" do
      private = create(:notification, user: create(:user))
      patch :update_all, params: params
      expect(private.reload.read).to be_falsey
    end

  end

  describe "DELETE 'destroy'" do

    before(:each) do
      sign_in user
      note
    end

    let(:params) {
      {
        user_id: user,
        id: note.to_param
      }
    }

    it "should delete notice" do
      expect {
        delete :destroy, params: params
      }.to change(Notification, :count).by(-1)
    end

    it "should flash success" do
      delete :destroy, params: params
      expect(flash[:success]).to match /notification deleted/i
    end

    it "should redirect to index" do
      delete :destroy, params: params
      expect(response).to redirect_to notifications_url
    end


  end

  describe "DELETE 'destroy_all'" do

    let(:destroy_all) { delete :destroy_all, params }

    before(:each) do
      sign_in user
    end

    context "when there are no notifications" do

      before(:each) { delete :destroy_all, params: params }

      it "should flash failed if no notifications" do
        expect(flash[:failed]).to match /No notifications to delete/i
      end
    end

    context "when there are notifications" do
      before do
        note
        delete :destroy_all, params: params
      end
      it "should delete all notifications" do
        expect(Notification.count).to eq 0
      end
      it "should flash success" do
        expect(flash[:success]).to match /all notifications have been deleted/i
      end
      it "should redirect to index" do
        expect(response).to redirect_to notifications_url
      end
    end

    it "should delete only read posts if condition is selected" do
      note
      create(:notification, read: true, user: user)
      expect {
        delete :destroy_all, params: params.merge( condition: "read" )
      }.to change(Notification, :count).by(-1)
    end

    it "should respect since conditions" do
      create(:notification, user: user)
      note.update_attribute(:created_at, 2.days.ago)
      expect {
        delete :destroy_all, params: params.merge( time_unit: "days", time: 1 )
      }.to change(Notification, :count).by(-1)
    end
  end
end
