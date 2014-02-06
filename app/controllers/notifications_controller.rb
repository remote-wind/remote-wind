class NotificationsController < ApplicationController

  before_filter :authenticate_user!

  # Display notifications belonging to the currently logged in user.
  # GET notifications
  def index
    @user = current_user
    @notifications = Notification
            .where(user_id: @user.id)
            .order(created_at: :desc)
            .paginate(page: params[:page])

    # Render response before marking notifications as read
    respond_to do |format|
      format.html { render :index }
    end
    # Mark notifications as read after page has been rendered
    @notifications.update_all(read: true) if @notifications.present?
  end

end