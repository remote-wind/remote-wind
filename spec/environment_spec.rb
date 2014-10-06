describe ENV, "This is a sanity check to make sure your local enviroment is set up" do

  describe "['REMOTE_WIND_EMAIL']" do
    subject { super()['REMOTE_WIND_EMAIL'] }
    it { is_expected.not_to be_blank }
  end

  describe "['REMOTE_WIND_PASSWORD']" do
    subject { super()['REMOTE_WIND_PASSWORD'] }
    it { is_expected.not_to be_blank }
  end

  describe "['REMOTE_WIND_GEONAMES']" do
    subject { super()['REMOTE_WIND_GEONAMES'] }
    it { is_expected.not_to be_blank }
  end

  describe "['REMOTE_WIND_FB_APP_ID']" do
    subject { super()['REMOTE_WIND_FB_APP_ID'] }
    it { is_expected.not_to be_blank }
  end

  describe "['REMOTE_WIND_FB_APP_SECRET']" do
    subject { super()['REMOTE_WIND_FB_APP_SECRET'] }
    it { is_expected.not_to be_blank }
  end

end