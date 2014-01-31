class NotificationsController < ApplicationController

  before_filter :authenticate_user!

  # GET notifications
  def index
    @user = current_user
    @notifications = Notification.where(user_id: @user.id)
    authorize! :read, @notifications
  end

end