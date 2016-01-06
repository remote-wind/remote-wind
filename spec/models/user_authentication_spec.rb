# == Schema Information
#
# Table name: user_authentications
#
#  id                         :integer          not null, primary key
#  user_id                    :integer
#  authentication_provider_id :integer
#  uid                        :string(255)
#  token                      :string(255)
#  token_expires_at           :datetime
#  params                     :text
#  created_at                 :datetime
#  updated_at                 :datetime
#  provider_name              :string(255)
#

require 'spec_helper'

describe UserAuthentication, type: :model do

  let(:user) {
    user = create(:user)
    user.authentications.create(attributes_for(:user_authentication))
  }

  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :authentication_provider }
  it { is_expected.to respond_to :uid }
  it { is_expected.to respond_to :token }

  specify "destroying user should remove authentications" do
    user
    expect {
      user.destroy
    }.to change(UserAuthentication, :count).by(-1)
  end
end
