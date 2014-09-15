class UserMailer < ActionMailer::Base

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.test.subject
  #
  # @param [User|String] recipient - can be used with a email address or a User
  def test(recipient)
    mail to: recipient.is_a?(User) ? recipient.email : recipient
  end
end
