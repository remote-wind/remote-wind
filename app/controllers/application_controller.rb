class ApplicationController < ActionController::Base

  before_filter :get_all_stations, :get_notifications
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include ActionView::Helpers::TextHelper

  # Tell devise to redirect to root instead of user#show
  def after_sign_in_path_for(resource)
    root_path
  end

  # Setup geonames user name
  Timezone::Configure.begin do |c|
    c.username = ENV['REMOTE_WIND_GEONAMES']
  end

  ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
    html_tag.html_safe
  end

  # GET /honeypot
  def honeypot
    raise CanCan::AccessDenied and return
  end

  # Handle authentication errors
  rescue_from CanCan::AccessDenied do |exception|
    if user_signed_in?
      redirect_to root_url
    else
      redirect_to new_user_session_path
    end
  end

  # since the stations are used by all
  def get_all_stations

    if user_signed_in? && current_user.has_role?(:admin)
        @all_stations = Station.includes(:measures).to_a
    end

    @all_stations ||= Station.includes(:measures).where(show: true)
  end

  # Get notifications
  def get_notifications
    if user_signed_in?
      count = Notification.where(user: current_user, read: false).count
      if count > 0
        flash[:notice] = view_context.link_to(
            "You have #{pluralize(count, 'unread notification')}.", notifications_path
        )
        @unread_notifications_count = count
      end
    end

  end


end