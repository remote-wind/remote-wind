module Services
  module Notifiers
    # Notifies owner when a station has a low balance on the prepaid SIM card.
    class LowBalance < StationEventNotifier
      def self.message(station)
        "#{station.name} has a low balance, only #{station.balance} kr left."
      end
      def self.event
        "station_low_balance"
      end
    end
  end
end