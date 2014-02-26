class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_user, except: [:index]
  load_and_authorize_resource

  # GET /users/:id
  def show
    @title = @user.nickname
    @available_roles =  Role.all.keep_if do |role|
      !@user.has_role?(role.name.to_sym)
    end
  end

  # GET /users/
  def index
    @title = "Users"
    @users = User.all
  end

  # DESTROY /users/:id
  def destroy
    if @user == current_user
      return redirect_to users_path, :flash => { :alert => "You cannot delete your own accout!" }
    end

    @user.destroy!
    redirect_to users_path, :flash => { :success => "User deleted." }
  end

  protected

  def set_user
    @user = User.friendly.find(params[:id])
  end

end
