class ApplicationController < ActionController::Base

  include ActionView::Helpers::TextHelper

  protect_from_forgery with: :exception

  before_filter :get_all_stations, if: -> { get_all_stations? }
  before_filter :get_notifications, if: -> { user_signed_in? }

  # OPT OUT security model
  before_filter :authenticate_user!, except: [:honeypot], unless: -> { user_signed_in? }

  # Ensure authorization with CanCan
  # https://github.com/ryanb/cancan/wiki/Ensure-Authorization
  check_authorization unless: :devise_controller?

  # Tell devise to redirect to root instead of user#show
  def after_sign_in_path_for(resource)
    root_path
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
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
        @all_stations = Station.all.load
    end

    @all_stations ||= Station.where(show: true).load

    measures = Measure.find_by_sql(%Q{
      SELECT DISTINCT ON(m.station_id)
        m.*
      FROM measures m
      ORDER BY m.station_id, m.created_at ASC
    })

    @all_stations.each do |station|
      station.current_measure = measures.bsearch { |m| m.station_id == station.id  }
    end

    # Add methods to search for station in collection
    @all_stations.extend(Slugged)
  end

  def get_all_stations?

    true unless \
      ['json', 'xml', 'yaml'].include?(request['format'])

  end

  # Get notifications
  def get_notifications
    count = Notification.where(user: current_user, read: false).count
    if count > 0
      flash[:notice] = view_context.link_to(
          "You have #{pluralize(count, 'unread notification')}.", user_notifications_path(user_id: current_user)
      )
      @unread_notifications_count = count
    end
  end
end