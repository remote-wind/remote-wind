class UsersController < ApplicationController
  load_and_authorize_resource
  before_filter :authenticate_user!

  # GET /users/:id
  def show
    @user = User.find(params[:id])
  end

  # GET /users/
  def index
    @users = User.all
  end
end
