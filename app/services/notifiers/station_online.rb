module Services
  module Notifiers
    # Notifies owner when a station is back online.
    class StationOnline < StationEventNotifier
      def self.message(station)
        "Your station #{station.name} has started to respond and we are now receiving data from it."
      end
      def self.event
        "station_online"
      end
    end
  end
end
