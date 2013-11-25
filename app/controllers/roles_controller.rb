class RolesController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource

  def create
    user = User.find(params[:user_id])
    role = Role.find_by_name(params[:role][:name])
    if role
      user.add_role role.name
    end
  end

  def destroy
    user = User.find(params[:user_id])
    role = Role.find(params[:id])
    user.remove_role(role.name.to_sym)
  end
end