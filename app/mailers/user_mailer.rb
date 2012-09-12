class UserMailer < Devise::Mailer

  def notify_about_new_station(user, station)
    @station  = station
    mail :to => user.email, :subject => "Your station has been registered!" do |format|
      format.html
    end
  end
end