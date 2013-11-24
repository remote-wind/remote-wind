describe ENV, "This is a sanity check to make sure your local enviroment is set up" do

  its(['REMOTE_WIND_EMAIL']) { should_not be_blank }
  its(['REMOTE_WIND_PASSWORD']) { should_not be_blank }
  its(['REMOTE_WIND_GEONAMES']) { should_not be_blank }
  its(['REMOTE_WIND_FB_APP_ID']) { should_not be_blank }
  its(['REMOTE_WIND_FB_APP_SECRET']) { should_not be_blank }

end