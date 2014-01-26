class StationMailer < ActionMailer::Base
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.station_mailer.notify_about_low_balance.subject
  # @return Mail::Message
  #
  def notify_about_low_balance user, station
    @station = station
    @mail = mail :to => user.email, :subject => "Low balance for your station #{station.name}" do |format|
      format.html
    end
    unless @mail.nil?
      @mail.deliver
    end
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.station_mailer.notify_about_station_down.subject
  # @return Mail::Message
  #
  def notify_about_station_down user, station
    @station  = station
    unless user.nil? && user.email.nil?
      @mail = mail :to => user.email, :subject => "Your station #{station.name} has not responded for 15 minutes." do |format|
        format.html
      end
      if !!@mail
        unless @mail.deliver
          Rails.logger.error('StationMailer.notify_about_station_down: Email could not be delivered')
        end
      else
        Rails.logger.error('StationMailer.notify_about_station_down: Mail could not be created')
      end
    end
  end
  
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.station_mailer.notify_about_station_down.subject
  #
  def notify_about_station_up user, station
    @station  = station
    if !user.nil? && !user.email.nil? # due to tests do note set email
      @mail = mail :to => user.email, :subject => "Your station #{station.name} has started to respond and we are now receiving data from it." do |format|
        format.html
      end
      if !!@mail
        unless @mail.deliver
          Rails.logger.error('StationMailer.notify_about_station_up: Email could not be delivered')
        end
      else
        Rails.logger.error('StationMailer.notify_about_station_up: Mail could not be created')
      end
    end
  end
end
