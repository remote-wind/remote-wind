class StationMailer < ActionMailer::Base
  default from: "from@example.com"

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
      unless @mail.nil?
        @mail.deliver
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
    unless user.nil? && user.email.nil? # due to tests do note set email
      @mail = mail :to => user.email, :subject => "Your station #{station.name} has started to respond and we are now receiving data from it." do |format|
        format.html
      end
      unless @mail.nil?
        @mail.deliver
      end
    end
  end
end
