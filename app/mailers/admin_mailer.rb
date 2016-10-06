# @todo CLEANUP - should not hardcorde TO address
class AdminMailer < Devise::Mailer

  #
  # @param user [User]

  def notify_about_new_user(user)
    @user = user
    mail(to:"info@yelloworb.com", subject:"New user registered at remote wind") do |format|
      format.html
    end
  end

  # @todo CLEANUP - can unregistered users still create stations?
  # I dont think so
  def notify_about_new_station_without_owner(station)
    @station = station
    mail(to:"info@yelloworb.com", subject:"New station but now owner set") do |format|
      format.html
    end
  end

  def notify_about_new_station_and_invitation(email, station)
    @station = station
    @email = email
    mail(to:"info@yelloworb.com", subject:"New station created and user invited") do |format|
      format.html
    end
  end

  def notify_about_new_station(user, station)
    @station = station
    @user = user
    mail(to:"info@yelloworb.com", subject:"New station") do |format|
      format.html
    end
  end
end
