class DevelopmentTestMailInterceptor  
  def self.delivering_email(message)  
    message.subject = "[#{message.to}] #{message.subject}"  
    message.to = "karl-petter@yelloworb.com"  
  end  
end


#ActionMailer::Base.smtp_settings =  {
#  :address => 'smtp.yelloworb.com', 
#  :port => 465,
#  :domain => 'yelloworb.com',
#  :user_name => 'webapp@yelloworb.com',
#  :password => 'us32sENDm@1l',
#  :authentication => 'plain',
#  :enable_starttls_auto => true,
#  :openssl_verify_mode  => 'none'
#}
ActionMailer::Base.smtp_settings =  {
  :address => 'smtp.gmail.com', 
  :port => 587,
  :domain => 'yelloworb.com',
  :user_name => 'yelloworbwebapp@gmail.com',
  :password => 'us32sENDm@1l',
  :authentication => 'plain',
  :enable_starttls_auto => true
}
ActionMailer::Base.default :charset => "utf-8"
ActionMailer::Base.default :from =>  'support@yelloworb.com'

# change so any mails from test or development will go to karl-petter@movintofun.com
ActionMailer::Base.register_interceptor(DevelopmentTestMailInterceptor) if Rails.env.development?  || Rails.env.test?