module StationsHelper

  # Create link to clear measures for station
  #@param station Station
  #@param options Hash
  #@return string
  def clear_measures_button(station, options = {})
    options.merge!({
        text: "Clear all measures for this station?",
        data:  {
          confirm:   "Are you sure you want to delete all measues recorded by this station? This action cannot be undone!"
        },
        class: "tiny button alert",
        method:  :delete
    })
    link_to options[:text], station_measures_path(station), options
  end

  #@param station Station
  #@return String station name + (offline)
  def station_header(station)
    (station.down? ? station.name + "(#{content_tag(:em, 'offline')})" : station.name).html_safe
  end

  def station_coordinates(station)
    sprintf('data-lat="%d" data-lng="%d"', station.latitude, station.longitude).html_safe
  end

end
