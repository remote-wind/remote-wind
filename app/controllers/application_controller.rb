class ApplicationController < ActionController::Base
  protect_from_forgery
  check_authorization # enforce CanCan authorization on all methods
  before_filter :get_five_last_updated_stations
  
  protected
  def get_five_last_updated_stations
   # @last_five_updated_stations = Rails.cache.fetch('five_last_upated_stations', :expires_in => 10.minutes) do      
      @last_five_updated_stations = Station.find(:all, :order => "updated_at desc", :limit => 5)
   # end
  end
  
end
