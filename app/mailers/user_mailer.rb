class UserMailer < ActionMailer::Base

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.test.subject
  #
  def test(user)
    @greeting = "Hi"
    mail to: user.email
  end
end
