class NotificationsController < ApplicationController

  # GET notifications
  def index
    authenticate_user!
    @user = current_user
    @notifications = Notification.where(user_id: @user.id)
    authorize! :read, @notifications
  end

end
 