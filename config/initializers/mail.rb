class DevelopmentTestMailInterceptor  
  def self.delivering_email(message)  
    message.subject = "[#{message.to}] #{message.subject}"  
    message.to = ENV["REMOTE_WIND_EMAIL"]
  end  
end

ActionMailer::Base.smtp_settings =  {
  :address => 'smtp.gmail.com', 
  :port => 587,
  :domain => 'yelloworb.com',
  :user_name => 'yelloworbwebapp@gmail.com',
  :password => ENV["REMOTE_WIND_EMAIL_PASSWORD"],
  :authentication => 'plain',
  :enable_starttls_auto => true
}

ActionMailer::Base.default :charset => "utf-8"
ActionMailer::Base.default :from =>  'support@yelloworb.com'

# change so any mails from development will go to karl-petter@movintofun.com
ActionMailer::Base.register_interceptor(DevelopmentTestMailInterceptor) if Rails.env.development?