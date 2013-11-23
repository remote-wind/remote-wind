module MeasuresHelper

  def degrees_and_cardinal degrees
    "#{degrees} (#{ Geocoder::Calculations.compass_point(degrees) })"
  end

  def speed_min_max(measure)
    "%{speed} (%{min_wind_speed}/%{max_wind_speed})" % measure
  end

end