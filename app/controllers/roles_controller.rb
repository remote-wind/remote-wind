class RolesController < ApplicationController

  authorize_resource

  def create
    @user = User.find(params[:user_id])
    @role = Role.find(params[:user][:roles])
    if @role
      @user.add_role @role.name
    end

    respond_to do |format|
      format.html { redirect_to @user, notice: "user now is a #{@role.name.to_s}" }
      format.json { render action: 'user#show', status: :created, location: @user }
    end
  end

  def destroy
    @user = User.find(params[:user_id])
    @role = Role.find(params[:user][:roles])
    @user.remove_role(@role.name.to_sym)
    respond_to do |format|
      format.html { redirect_to @user, notice: 'Role was revoked.' }
      format.json { head :no_content }
    end
  end
end