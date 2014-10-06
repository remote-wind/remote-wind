shared_examples "a observation" do
  describe "attributes" do
    describe '#id' do
      subject { super().id }
      it { is_expected.not_to be_nil }
    end # indicates a false postive!

    describe '#id' do
      subject { super().id }
      it { is_expected.to eq attributes[:id] }
    end

    describe '#station_id' do
      subject { super().station_id }
      it { is_expected.to eq attributes[:station_id] }
    end

    describe '#speed' do
      subject { super().speed }
      it { is_expected.to eq attributes[:speed] }
    end

    describe '#direction' do
      subject { super().direction }
      it { is_expected.to eq attributes[:direction] }
    end

    describe '#max_wind_speed' do
      subject { super().max_wind_speed }
      it { is_expected.to eq attributes[:max_wind_speed] }
    end

    describe '#min_wind_speed' do
      subject { super().min_wind_speed }
      it { is_expected.to eq attributes[:min_wind_speed] }
    end

    describe '#created_at' do
      subject { super().created_at }
      it { is_expected.to eq "1999-12-31T23:00:00Z" }
    end

    describe '#tstamp' do
      subject { super().tstamp }
      it { is_expected.to eq Time.new(2000).to_i }
    end
  end
end