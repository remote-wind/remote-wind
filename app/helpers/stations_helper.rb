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

  # Gets all the valid time zones for rails in a format for a select
  # @return [Array]
  def timezone_options
    ActiveSupport::TimeZone::MAPPING.values
  end

  # @return [String]
  # @param [Station] station
  # @param [Hash] opts
  #  any keywords are passed on to content_tag
  # @example station_status_indicator(Station.new(status: active))
  #   <span class="status active">Ok</span>
  # @example station_status_indicator(Station.new(status: active), foo: bar, element: :div)
  #   <div class="status active" foo="bar">Ok</div>
  def station_status_indicator(station, element: :span, **opts)
    text = I18n.t!("station.statuses.#{station.status}")
    content_tag(element, text, opts.reverse_merge(
      class: ['status', station.status].join(' ')
    ))
  end

  # Creates a DIV tag for a leaflet map canvas
  # @param [Station|nil] station
  # @yeilds Yields inside DIV if passed a block
  # @return [String] or some kind of string like safe buffer object
  def leaflet_tag(station = nil, **kwargs)
    css_classes = %w[map-canvas small-12 large-12 columns]
    css_classes << "#{controller_name}-#{action_name}"
    css_classes << kwargs[:class]
    opts = {
      id: "map_canvas",
      class: css_classes.compact.join(' '),
      data: {
        lat: station.try(:latitude) || 63.399444,
        lng: station.try(:longitude) || 13.081667
      }
    }
    content_tag :div, opts do
      yield if block_given?
    end
  end
end
