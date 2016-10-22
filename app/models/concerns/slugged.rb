# Hacky way to select stations by id or slug
# @todo CLEANUP - can be removed by using friendly_id properly?
module Slugged
  def select_by_slug_or_id param
    station = select { |station| [ station.slug, station.id].include?( param ) }
    station.first if station.length.nonzero?
  end
end
