class StationMailer < ActionMailer::Base
  # @note Subject should be set via I18n file at config/locales/en.yml
  #   with the following key:
  #     en.station_mailer.low_balance.subject
  # @param station [Station]
  # @param options [Hash]
  # @return [Mail::Message|nil] nil if mail could not be created
  def low_balance(station, options = {})
    @balance = station.balance
    send_mail(station, options.merge!(
        message_handler: __method__,
        subject: "Low balance for your station #{station.name}"
    ))
  end

  # @note Subject should be set via I18n file at config/locales/en.yml
  #   with the following key:
  #     en.station_mailer.offline.subject
  # @param station [Station]
  # @param options [Hash]
  # @return [Mail::Message|nil] nil if mail could not be created
  def offline(station, options = {})
    send_mail(station, options.merge!(
        message_handler: __method__,
        subject: "Your station #{station.name} has not responded for 15 minutes."
    ))
  end

  # @note Subject should be set via I18n file at config/locales/en.yml
  #   with the following key:  
  #     en.station_mailer.offline.subject
  # @param station [Station]
  # @param options [Hash]
  # @return [Mail::Message|nil] nil if mail could not be created
  def online(station, options = {})
    send_mail(station, options.merge!(
        message_handler: __method__,
        subject: "Your station #{station.name} has started to respond and we are now receiving data from it."
    ))
  end

  private
    # @param station [Station]
    # @param options [Hash]
    # @return [Mail::Message|nil] nil if mail could not be created
    def send_mail(station, options)
      @station = station
      @link = MarkdownHelper.link_to(@station.name, station_url(@station.id))
      options.merge!(
          to: station.try(:user).try(:email)
      )
      message = mail(options) do |format|
        format.text
        format.html
      end
      options[:message_handler] = "StationMailer##{options[:message_handler].to_s}"
      if message
        unless message.deliver
          Rails.logger.error("#{options[:message_handler]}: Email could not be delivered")
        end
      else
        Rails.logger.error("#{options[:message_handler]}: Mail could not be created")
      end
      message
    end
end
