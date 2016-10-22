class UserMailer < ActionMailer::Base

  # @note Subject should be set via I18n file at config/locales/en.yml
  #   with the following key:
  #     en.user_mailer.test.subject
  # @param recipient [User|String]  - can be used with a email address or a User
  # @return [Mail::Message|nil] nil if mail could not be created
  def test(recipient)
    email = recipient.is_a?(User) ? recipient.email : recipient
    mail(to: email) do |format|
      format.text
      format.html
    end
  end
end
