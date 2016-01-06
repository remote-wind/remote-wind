module Services
  module Notifiers
    # Notifies owner when a station has a low balance on the prepaid SIM card.
    class StationEventNotifier
      def self.message(station)
        raise 'StationEventNotifier subclasses must implement the .message class method'
      end

      def self.event
        raise 'StationEventNotifier subclasses must implement the .event class method'
      end
      
      def self.level
        :info
      end

      def self.mailer_method
        event.sub("station_", '').to_sym
      end

      # @param [Station] station
      # @return [Void]
      def self.call(station)
        msg = self.message(station)
        Rails.logger.info(msg)
        notified = Notification
                       .where(message: msg)
                       .since(12.hours.ago)
                       .count > 0
        unless notified
          mail = StationMailer.send(self.mailer_method, station)
          mail.deliver_now
          Notification.create!(
              user: station.user,
              level: self.level,
              message: msg,
              event: self.event
          )
        end
      end
    end
  end
end