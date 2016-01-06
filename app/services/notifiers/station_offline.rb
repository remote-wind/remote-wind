module Services
  module Notifiers
    # Notifies owner when a station has a low balance on the prepaid SIM card.
    class StationOffline < StationEventNotifier
      def self.message(station)
        "Your station #{station.name} has not responded for 15 minutes."
      end
      def self.event
        "station_offline"
      end
      def self.level
        :warning
      end
    end
  end
end