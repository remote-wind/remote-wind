# Handles in-app notifications for station events.
class NotificationsController < ApplicationController
  # Display notifications belonging to the currently logged in user.
  before_action :authenticate_user!

  before_action :set_user
  before_action :set_notifications
  # GET /notifications
  def index
    @notifications = policy_scope(Notification).order(created_at: :desc)
                                               .paginate(page: params[:page])
    @title = "Inbox"
    @title += "(#{@unread_notifications_count})" unless @unread_notifications_count.nil?

    # Render response before marking notifications as read
    respond_to do |format|
      format.html { render :index }
    end
    # Mark notifications as read after page has been rendered
    @notifications.update_all(read: true) if @notifications.present?
  end

  # PATCH /notifications
  def update_all
    @notifications = policy_scope(Notification).where(read: false)
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
    @notification = current_user.notifications.find(params[:id])
    authorize(@notification)
    @notification.destroy
    flash[:success] = 'Notification deleted.'
    redirect_to action: :index
  end

  # DESTROY /notifications
  def destroy_all
    @notifications = policy_scope(Notification)
    @notifications = @notifications.where(read: true) if params[:condition] == 'read'
    # Use time input to limit chonographically
    if (!params[:time].nil? && !params[:time_unit].nil?)
      time = params[:time].to_i
      unit = ['days', 'weeks', 'months', 'years'].include?(params[:time_unit]) ?  \
          params[:time_unit].to_sym : nil
      @notifications = @notifications.where('created_at <= ?', time.send(unit).ago)
    end

    if @notifications.destroy_all.size.nonzero?
      flash[:success] = 'All notifications have been deleted.'
    else
      flash[:failed] = 'No notifications to delete.'
    end

    redirect_to action: :index
  end

  private

  def set_notifications
    @notifications = policy_scope(Notification)
  end

  def set_user
    @user = current_user
  end
end
