module MeasuresHelper

  def degrees_and_cardinal degrees
    if degrees
      "%s (%d°)" % [Geocoder::Calculations.compass_point(degrees), degrees]
    end
  end

  def speed_min_max(measure)

    unless measure.is_a? Hash
      measure = HashWithIndifferentAccess.new(measure.attributes)
    end

    if measure
      "%{speed} (%{min_wind_speed}-%{max_wind_speed})m/s" % measure
    end
  end

  def time_in_24h time
    time.strftime("%H:%M")
  end

  def time_date_hours_seconds time
    time.today? ? time.strftime("%H:%M") : time.strftime("%m/%d %H:%M")
  end
end