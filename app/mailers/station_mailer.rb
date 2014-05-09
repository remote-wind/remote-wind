class StationMailer < ActionMailer::Base
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  # en.station_mailer.notify_about_low_balance.subject
  # @param station Station
  # @param options Hash (optional)
  # @return Mail::Message | nil returns nil if mail could not be created
  def notify_about_low_balance station, options = {}
    send_mail(station, options.merge!(
        message_handler: __method__,
        subject: "Low balance for your station #{station.name}"
    ))
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  # en.station_mailer.notify_about_station_offline.subject
  # @param station Station
  # @param options Hash (optional)
  # @return Mail::Message | nil returns nil if mail could not be created
  def notify_about_station_offline station, options = {}
    send_mail(station, options.merge!(
        message_handler: __method__,
        subject: "Your station #{station.name} has not responded for 15 minutes."
    ))
  end
  
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  # en.station_mailer.notify_about_station_offline.subject
  # @param station Station
  # @param options Hash (optional)
  # @return Mail::Message | nil returns nil if mail could not be created
  def notify_about_station_online station, options = {}
    send_mail(station, options.merge!(
        message_handler: __method__,
        subject: "Your station #{station.name} has started to respond and we are now receiving data from it."
    ))
  end

  private

  # @param station Station
  # @param options Hash
  # @return Mail::Message | nil returns nil if mail could not be created
  def send_mail(station, options)
    @station = station

    options.merge!(
        to: station.try(:user).try(:email)
    )

    message = mail(options) do |format|
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

    return message
  end




end
