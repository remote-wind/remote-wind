require 'rails_helper'

RSpec.describe StationPolicy do

  let(:station) { Station.new }
  let(:owner) do
    user = User.new
    allow(user).to receive(:has_role?).with(:owner, station).and_return(true)
    allow(user).to receive(:has_role?).with(:admin).and_return(false)
    user
  end

  permissions ".scope" do
    let!(:active) { create(:station, status: :active) }
    let!(:unresponsive) { create(:station, status: :unresponsive) }
    let!(:deactivated) { create(:station, status: :deactivated) }
    let!(:not_initialized) { create(:station, status: :not_initialized) }

    context 'guest or unpriveledged users' do
      subject { policy_scope(create(:user)).resolve.map(&:status) }
      it { should include "active" }
      it { should include "unresponsive" }
      it { should_not include "deactivated" }
      it { should_not include "not_initialized" }
    end

    context 'admins' do
      subject { policy_scope(create(:admin)).resolve.map(&:status) }
      it { should include "active" }
      it { should include "unresponsive" }
      it { should include "deactivated" }
      it { should include "not_initialized" }
    end

    context 'owners' do
      let!(:station) { create(:station, status: :deactivated) }
      let!(:owner) do
        create(:user)
      end
      before do
        owner.add_role(:owner, station)
      end
      subject { policy_scope(owner).resolve }
      it { should include active }
      it { should include unresponsive }
      it { should include station }
      it { should_not include deactivated }
      it { should_not include not_initialized }
    end
  end

  permissions :show? do
    context 'guest or unpriveledged users' do
      specify "cant see deactivated stations" do
        expect(subject).to_not permit(User.new, Station.new(status: :deactivated))
      end
      specify "cant see unitialized stations" do
        expect(subject).to_not permit(User.new, Station.new(status: :not_initialized))
      end
      specify "can see active and unresponsive stations" do
        expect(subject).to_not permit(User.new, Station.new(status: :active))
        expect(subject).to_not permit(User.new, Station.new(status: :unresponsive))
      end
    end
    specify "admins can see stations with any status" do
      Station.statuses.keys.each do |status|
        expect(subject).to permit(admin, Station.new(status: status))
      end
    end
    specify "owners can see stations with any status" do
      Station.statuses.keys.each do |status|
        station.status = status
        expect(subject).to permit(owner, station)
      end
    end
  end

  permissions :create? do
    it "only allows admins" do
      expect(subject).to_not permit(User.new, Station)
      expect(subject).to permit(admin, Station)
    end
  end

  permissions :update? do
    it "does not allow guest users" do
      expect(subject).to_not permit(User.new, station)
    end
    it "allows admins" do
      expect(subject).to permit(admin, station)
    end
    it "allows owners" do
      expect(subject).to permit(owner, station)
    end
  end

  permissions :destroy? do
    it "does not allow guest users" do
      expect(subject).to_not permit(User.new, station)
    end
    it "allows admins" do
      expect(subject).to permit(admin, station)
    end
    it "allows owners" do
      expect(subject).to permit(owner, station)
    end
  end

  permissions :api_firmware_version? do
    it "permits anyone" do
      expect(subject).to permit(User.new, Station.new)
    end
  end

  permissions :update_balance? do
    it "permits anyone" do
      expect(subject).to permit(User.new, Station.new)
    end
  end

  permissions :find? do
    it "permits anyone" do
      expect(subject).to permit(User.new, Station.new)
    end
  end

  permissions :search? do
    it "permits anyone" do
      expect(subject).to permit(User.new, Station.new)
    end
  end

  describe "#permitted_attributes" do
    subject { permitted_attributes }
    it { should_not include :id }
    it { should include :name }
    it { should include :hw_id }
    it { should include :latitude }
    it { should include :longitude }
    it { should include :user_id }
    it { should include :slug }
    it { should include :speed_calibration }
    it { should include :description }
    it { should include :sampling_rate }
    it { should include :status }
    it { should include :timezone }
  end
end
