require 'spec_helper'

describe UserAuthentication do

  let(:user) {
    user = create(:user)
    user.authentications.create(attributes_for(:user_authentication))
  }

  it { should belong_to :user }
  it { should belong_to :authentication_provider }
  it { should respond_to :uid }
  it { should respond_to :token }

  specify "destroying user should remove authentications" do
    user
    expect {
      user.destroy
    }.to change(UserAuthentication, :count).by(-1)
  end
end
