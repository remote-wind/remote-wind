module StationsHelper

  #@param station Station
  #@param options Hash
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
  def station_header(station)
    station.down? ? station.name + '<em>offline</em>'.html_safe : station.name
  end

end
