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

class UserAuthentication < ActiveRecord::Base
  belongs_to :user
  belongs_to :authentication_provider

  serialize :params

  def self.create_from_omniauth(params, user, provider)
    params = HashWithIndifferentAccess.new(params)
    create(
      provider_name: provider.name.capitalize!,
      user: user,
      authentication_provider: provider,
      uid: params['uid'],
      token: params['credentials']['token'],
      token_expires_at: Time.at(params['credentials']['expires_at']).to_datetime,
      params: params,
    )

  end

  alias :provider :authentication_provider


end
