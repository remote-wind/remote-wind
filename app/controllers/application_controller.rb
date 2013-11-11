class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

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

end