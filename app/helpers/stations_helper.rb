module StationsHelper

  # Create link to clear observations for station
  # @param station [Station]
  # @param options [Hash]
  # @return [String]
  def clear_observations_button(station, options = {})
    options.merge!({
        text: "Clear all observations for this station?",
        data:  {
          confirm:   "Are you sure you want to delete all measues recorded by this station? This action cannot be undone!"
        },
        class: "tiny button alert",
        method:  :delete
    })
    link_to options[:text], station_observations_path(station), options
  end

  # @param station [Station]
  # @return [String]
  # @example when status == active
  #   station_header(station)
  #   => "Test station"
  # @example when status == "not_initialized"
  # @todo Use i18n to translate statuses
  #   station_header(station)
  #   => "Test station(<em>not initalized</em>)"
  def station_header(station)
    unless station.active?
      ( station.name + "(#{content_tag(:em, station.status.titleize.downcase )})" ).html_safe
    else
      station.name
    end
  end

  # @todo CLEANUP
  # @param station [Station]
  # @return [String]
  def station_coordinates(station)
    sprintf(
      'data-lat="%d" data-lng="%d"',
      station.latitude,
      station.longitude).html_safe
  end

  # Displays a duration as a digital timer format
  # @param station [ActiveSupport::Duration]
  # @return [String]
  # @example readable_duration(1.hours)
  #   => "01:30:00"
  def readable_duration(duration)
    Time.at(duration.to_i).utc.strftime("%H:%M:%S")
  end

  def timezone_options
    ActiveSupport::TimeZone::MAPPING.values
  end
end
