# @see environments/[production.rb/devleopment.rb] for SMTP settings
ActionMailer::Base.default(
    charset: 'utf-8',
    from: ENV['REMOTE_WIND_DEFAULT_FROM_EMAIL'] || 'support@yelloworb.com'
)