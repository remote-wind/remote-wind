if Rails.env.development?
  # Use Mailcatcher (https://github.com/sj26/mailcatcher) to catch mails in development
  ActionMailer::Base.smtp_settings = { :address => "localhost", :port => 1025 }
else
  ActionMailer::Base.smtp_settings =  {
    :address => 'smtp.gmail.com',
    :port => 587,
    :domain => 'yelloworb.com',
    :user_name => 'yelloworbwebapp@gmail.com',
    :password => ENV["REMOTE_WIND_EMAIL_PASSWORD"],
    :authentication => 'plain',
    :enable_starttls_auto => true
  }
end

ActionMailer::Base.default :charset => "utf-8"
ActionMailer::Base.default :from =>  'support@yelloworb.com'
