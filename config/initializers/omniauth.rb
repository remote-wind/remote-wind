Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['REMOTE_WIND_FB_APP_ID'], ENV['REMOTE_WIND_FB_APP_SECRET'],
          { scope: "email", display: "touch", image_size: { height: 25, width: 25 } }
end

