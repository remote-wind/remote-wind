require 'rails_helper'

RSpec.describe ObservationPolicy do

  let(:station) { create(:station) }
  let(:observation) { create(:observation, station: station) }

  permissions ".scope" do
    before { observation }
    subject { policy_scope(user).resolve }
    it { should eq Observation.all }
  end

  permissions :show? do
    it { should permit(User.new, observation) }
  end

  permissions :create? do
    it { should permit(User.new, Observation) }
  end

  permissions :update? do
    it { should_not permit(User.new, observation) }
    it { should permit(create(:admin), observation) }
  end

  permissions :destroy? do
    it { should_not permit(User.new, Observation.new) }
    it { should permit(create(:admin), observation) }
  end

  describe "#permitted_attributes" do
    subject { permitted_attributes }
    it { should_not include :id }
    it { should_not include :station_id }
    it { should include :direction }
    it { should include :speed }
    it { should include :min_wind_speed }
    it { should include :max_wind_speed }
  end
end
