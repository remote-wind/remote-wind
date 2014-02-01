class NotificationsController < ApplicationController

  before_filter :authenticate_user!


  # GET notifications
  def index
    @user = current_user
    @notifications = Notification.where(user_id: @user.id)

    respond_to do |format|
      format.html { render :index }
    end

    @notifications.update_all(read: true)
  end


end