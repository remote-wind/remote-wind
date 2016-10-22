module ObservationsHelper
  # Used to display both the cardinal (general compass direction)
  # and degrees from north
  # @param degrees [FixNum]
  # @example degrees_and_cardinal(90)
  #  =>  "E (90°)"
  # @return [String]
  def degrees_and_cardinal(degrees)
    if degrees
      "%s (%d°)" % [Geocoder::Calculations.compass_point(degrees), degrees]
    end
  end

  # Makes a formatted string for displaying wind speed.
  # @param []
  # @return [String]
  # @example speed_min_max( Observation.new(speed: 5, min: 2, max: 7) )
  #   => "5 (2-7)m/s"
  def speed_min_max(observation)
    unless observation.is_a? Hash
      observation = HashWithIndifferentAccess.new(observation.attributes)
    end
    if observation
      "%{speed} (%{min_wind_speed}-%{max_wind_speed})m/s" % observation
    end
  end

  # Display a time in 24h format.
  # @todo FIX - this does not properly handle timezones
  # @param time [DateTime|Time|TimeWithZone]
  # @return [String]
  def time_in_24h(time)
    time.strftime("%H:%M")
  end

  # Display a time and the date unless the time is during the current day.
  # @todo FIX - this does not properly handle timezones
  # @param time [DateTime|Time|TimeWithZone]
  # @return [String]
  def time_date_hours_seconds(time)
    time.today? ? time_in_24h(time) : time.strftime("%m/%d %H:%M")
  end
end
