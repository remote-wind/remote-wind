require "spec_helper"

feature "roles" do

  let!(:admin) { sign_in! create(:admin) }
  let!(:user) { create(:user) }

  context "when an admin" do

    describe "adds a role to user from the user page, it" do

      before(:each) do
        visit user_path(user)
        within(:css, ".add-role") do
          select "admin", from: "Role"
          click_button "Add role"
        end
      end

      it "adds a role to user" do
        expect(user.has_role? :admin).to be_truthy
      end

      it "redirects back to user page" do
        expect(current_path).to eq user_path(user)
      end

      it "displays a flash message" do
        expect(page).to have_content "user now is a admin"
      end
    end

    describe "removes a role to user from the user page, it" do
      before(:each) do
        user.add_role(:admin)
        visit user_path(user)
        within(:css, ".remove-role") do
          select "admin", from: "Role"
          click_button "Remove role"
        end
      end

      it "removes a role to user" do
        expect(user.has_role? :admin).to be_falsey
      end

      it "redirects back to user page" do
        expect(current_path).to eq user_path(user)
      end

      it "displays a flash message" do
        expect(page).to have_content "Role was revoked."
      end
    end
  end
end