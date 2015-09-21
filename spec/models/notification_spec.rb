# == Schema Information
#
# Table name: notifications
#
#  id         :integer          not null, primary key
#  event      :string(255)
#  message    :text
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  read       :boolean          default(FALSE)
#  level      :integer
#

require "spec_helper"

describe Notification, type: :model do

  it { is_expected.to belong_to :user }
  it { is_expected.to respond_to :event }
  it { is_expected.to respond_to :message }
  it { is_expected.to respond_to :read }

  describe "level" do
    it "should not validate a value not in LEVELS_RFC_5424" do
      subject.level = 52
      expect(subject.valid?).to be_falsey
    end
  end

  describe "#level=" do
    it "maps symbols to numeric values" do
      subject.level = :warning
      expect(subject.level).to eq 300
    end
  end

  describe "#level_to_symbol" do
    it "converts key to string" do
      subject.level = 300
      expect(subject.level_to_sym).to eq :warning
    end
  end

  describe "#level_to_s" do
    it "converts key to string" do
      subject.level = :warning
      expect(subject.level_to_s).to eq "warning"
    end
  end

  describe ".since" do
    it "does not return records older than the given time" do
      note = create(:notification, created_at: 1.day.ago)
      expect(Notification.since(1.hour.ago)).to_not include(note)
    end
    it "returns records in the correct span" do
      note = create(:notification, created_at: 1.minute.ago)
      expect(Notification.since(1.hour.ago)).to include(note)
    end
  end
end
