class UsersController < ApplicationController
  load_and_authorize_resource
  #skip_authorization_check :only => [:show, :about]
  before_filter :authenticate_user!
  
  def list
    @users = User.find(:all)
  end
  
end