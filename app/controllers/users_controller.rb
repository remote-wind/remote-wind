class UsersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  # GET /users/:id
  def show
    @user = User.find(params[:id])
  end

  # GET /users/
  def index
    @users = User.all
  end

  # DESTROY /users/:id
  def destroy
    @user = User.find(params[:id])

    if @user == current_user
      return redirect_to users_path, :flash => { :alert => "You cannot delete your own accout!" }
    end

    @user.destroy!
    redirect_to users_path, :flash => { :success => "User deleted." }
  end

end
