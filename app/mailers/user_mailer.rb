class UserMailer < Devise::Mailer

  def notify_about_new_station(user, station)
    @station  = station
    mail :to => user.email, :subject => "Your station has been registered!" do |format|
      format.html
    end
  end
  
  def notify_about_station_down(owner, station)
    @station  = station
    mail :to => owner.email, :subject => "Your station #{station.name} has not responded for 15 minutes." do |format|
      format.html
    end
  end
end