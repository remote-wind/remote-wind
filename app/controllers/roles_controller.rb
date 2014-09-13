class RolesController < ApplicationController

  authorize_resource
  before_filter :set_user, :set_role

  def create
    if @role
      @user.add_role @role.name
    end

    respond_to do |format|
      format.html { redirect_to @user, notice: "user now is a #{@role.name.to_s}" }
      format.json { render action: 'user#show', status: :created, location: @user }
    end
  end

  def destroy
    @user.remove_role(@role.name.to_sym)
    respond_to do |format|
      format.html { redirect_to @user, notice: 'Role was revoked.' }
      format.json { head :no_content }
    end
  end

  protected

  def set_user
    @user = User.friendly.find(params[:user_id])
  end

  def set_role
    @role = Role.find(params[:user][:roles])
  end

end