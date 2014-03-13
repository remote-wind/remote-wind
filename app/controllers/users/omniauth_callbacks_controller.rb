class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  skip_before_filter :verify_authenticity_token

  def facebook
    create
  end

  private

    def create
      auth_params = request.env["omniauth.auth"]

      unless auth_params.is_a?(OmniAuth::AuthHash)
        auth_params = OmniAuth::AuthHash.new(auth_params)
      end
      provider = AuthenticationProvider.where(name: auth_params.provider).first
      authentication = provider.user_authentications.where(uid: auth_params.uid).first

      if authentication
        authentication.user.update_from_omniauth(auth_params)
        sign_in_with_existing_authentication(authentication)

      elsif user_signed_in?
        create_authentication_and_sign_in(auth_params, current_user, provider)
      else
        create_user_and_authentication_and_sign_in(auth_params, provider)
      end
    end

    def sign_in_with_existing_authentication(authentication)
      authentication.user.update_attribute(:confirmed_at, Time.now) unless authentication.user.confirmed?
      flash[:success] = "Welcome back #{authentication.user.email}!"
      sign_in_and_redirect(:user, authentication.user)
    end

    def create_authentication_and_sign_in(auth_params, user, provider)
      @current_user = user
      @current_user.update_attribute(:confirmed_at, Time.now) unless @current_user.confirmed?
      UserAuthentication.create_from_omniauth(auth_params, @current_user, provider)
      sign_in_and_redirect(:user, @current_user)
    end

    def create_user_and_authentication_and_sign_in(auth_params, provider)
      user = User.find_by_email(auth_params[:info][:email]) || User.create_from_omniauth(auth_params)
      if user.valid?
        flash[:success] = "Welcome #{user.email}!"
        create_authentication_and_sign_in(auth_params, user, provider)
      else
        flash[:error] = user.errors.full_messages.first
        redirect_to new_user_registration_url
      end
    end
end
