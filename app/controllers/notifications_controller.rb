class NotificationsController < ApplicationController


  # GET notifications
  def index
    @user = current_user
    @notifications = Notification.where(user_id: @user.id)
  end

end
