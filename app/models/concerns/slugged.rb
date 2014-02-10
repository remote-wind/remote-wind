module Slugged
    def select_by_slug_or_id param
      station = select { |station| [ station.slug, station.id].include?( param ) }
      station.first if station.length.nonzero?
    end
end