module StationsHelper

  def is_index?
    params[:action] == 'index'
  end

  def speed_min_max(measure)
    "%{speed} (%{min_wind_speed}/%{max_wind_speed})" % measure
  end

end
