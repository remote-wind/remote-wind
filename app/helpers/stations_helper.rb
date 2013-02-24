require 'linefit'
module StationsHelper
  def direction_in_words(direction)
    case direction
    when 0..22
      "N"
    when 23..67
      "NO"
    when 68..112
      "O"
    when 113..157
      "SO"
    when 158..202
      "S"
    when 203..247
      "SW"
    when 248..292
      "W"
    when 293..337
      "NW"
    when 338..360
      "N"
    else
      ""
    end
  end
  
  def slope(x,y)
    lineFit = LineFit.new
    lineFit.setData(x,y)
    intercept, slope = lineFit.coefficients
    slope
  end
end
