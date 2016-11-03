# Users registered via OAuth don't have a password
# So we need to override the update method so that they can update their account
# without providing a password
class Users::RegistrationsController < Devise::RegistrationsController

  def create
    super
  end

  def update
    account_update_params = devise_parameter_sanitizer.sanitize(:account_update)

    # required for settings form to submit when password is left blank
    if account_update_params[:password].blank?
      account_update_params.delete("password")
      account_update_params.delete("password_confirmation")
    end

    @user = User.find(current_user.id)
    if @user.update_attributes(account_update_params)
      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      bypass_sign_in @user
      redirect_to after_update_path_for(@user), notice: "Your profile has been updated."
    else
      render :edit
    end
  end
end
