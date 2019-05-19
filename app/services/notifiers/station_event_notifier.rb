module Services
  module Notifiers
    # Used to constuct notifiers
    # @abstract
    class StationEventNotifier
      def self.message(station)
        raise NotImplementedError not_impemented_msg(__method__)
      end

      def self.event
        raise NotImplementedError not_impemented_msg(__method__)
      end

      def self.level
        :info
      end

      def self.mailer_method
        event.sub("station_", '').to_sym
      end

      # @param [Station] station
      # @return [Void]
      def self.call(station, logger: Rails.logger)
        msg = self.message(station)
        logger.info(msg)
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

      private
        def not_impemented_msg(method)
          "StationEventNotifier subclasses must implement .#{method}"
        end
    end
  end
end
