# Used to store user oauth authentications
# @attr id [Integer]
# @attr user_id [Integer]
# @attr authentication_provider_id [Integer]
# @attr uid [String]
# @attr token [String]
# @attr token_expires_at [DateTime]
# @attr params [String]
# @attr created_at [DateTime]
# @attr updated_at [DateTime]
# @attr provider_name [String]

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
