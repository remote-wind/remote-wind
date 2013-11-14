module MeasuresHelper

  def degrees_and_cardinal degrees
    "#{degrees} (#{ Geocoder::Calculations.compass_point(degrees) })"
  end
end
