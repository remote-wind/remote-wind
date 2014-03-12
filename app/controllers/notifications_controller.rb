class NotificationsController < ApplicationController

  authorize_resource

  skip_before_filter :get_notifications, only: [:mark_all_as_read]

  before_filter :set_user

  # Display notifications belonging to the currently logged in user.
  # GET /notifications
  def index

    @notifications = @user.notifications
            .order(created_at: :desc)
            .paginate(page: params[:page])

    @title = "Inbox"
    @title += " - page #{params[:page]}" unless params[:page].nil?

    # Render response before marking notifications as read
    respond_to do |format|
      format.html { render :index }
    end
    # Mark notifications as read after page has been rendered
    @notifications.update_all(read: true) if @notifications.present?
  end

  # PATCH /notifications/mark_all_as_read
  def mark_all_as_read

    @notifications = @user.notifications.where(read: false)

    if @notifications.update_all(read: true) > 0
      flash[:success] = 'All notifications have been marked as read.'
      redirect_to action: :index
    else
      flash[:error] = 'No unread notifications found.'
      redirect_to action: :index
    end

  end

  # DESTROY /notifications/:id
  def destroy
    @notification = @user.notifications.find(params[:id])
    @notification.destroy
    flash[:success] = 'Notification deleted.'
    redirect_to action: :index
  end

  # DESTROY /notifications
  def destroy_all

    @notifications = @user.notifications
    @notifications = @notifications.where(read: true) if params[:condition] == 'read'

    # Use time input to limit chonographically
    if (!params[:time].nil? && !params[:time_unit].nil?)
      time = params[:time].to_i
      unit = ['days', 'weeks', 'months', 'years'].include?(params[:time_unit]) ?  \
          params[:time_unit].to_sym : nil
      @notifications = @notifications.where('created_at >= ?', time.send(unit).ago)
    end

    if @notifications.destroy_all.size.nonzero?
      flash[:success] = 'All notifications have been deleted.'
    else
      flash[:failed] = 'No notifications to delete.'
    end

    redirect_to action: :index
  end

  def set_user
    @user = current_user
  end

end