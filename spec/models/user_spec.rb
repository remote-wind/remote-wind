# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default("")
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  image                  :string(255)
#  nickname               :string(255)
#  slug                   :string(255)
#  timezone               :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  invitation_token       :string(255)
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string(255)
#  invitations_count      :integer          default(0)
#

require 'spec_helper'

describe User do

  subject { build_stubbed(:user) }

  describe "attributes" do
    it { should respond_to :nickname }
    it { should respond_to :image }
    it { should respond_to :confirmed_at }
    it { should respond_to :confirmation_sent_at }
  end

  describe "validations" do
    it { should validate_presence_of :email }
    it { should validate_presence_of :password }
    it { should validate_uniqueness_of :email }
    it { should validate_uniqueness_of :nickname }
    it { should validate_uniqueness_of :confirmation_token }
  end

  describe "relations" do
    it { should have_and_belong_to_many :roles }
    it { should have_many :authentications }
    it { should have_many :notifications }
  end

  describe "timezone" do

    let(:user) { build_stubbed(:user) }

    it "should default to stockholm" do
      expect(user.timezone).to eq "Stockholm"
    end


    it "should accept a valid timezone" do
      user.timezone = 'Hawaii'
      user.valid?
      expect(user.errors.messages).to_not include :timezone
    end

    it "should reject an invalid zone name" do
      user.timezone = ActiveSupport::TimeZone.new('Sea of Tranquility')
      user.valid?
      expect(user.errors.messages).to include :timezone
    end

  end

  describe '#to_local_time' do
    let(:user) { build_stubbed(:user) }
    it "should convert time to users local time" do
      time = Time.iso8601("1970-01-01T01:00:00+00:00") # utc -0
      expect(user.to_local_time(time)).to eq time + 1.hour
    end
  end



  describe ".create_from_omniauth" do
    subject { User.create_from_omniauth(OmniAuth::MockFactory.facebook)  }
    its(:email) { should eq 'joe@bloggs.com' }
    its(:nickname) { should eq 'jbloggs' }
    its(:image) { should eq 'http://graph.facebook.com/1234567/picture?type=square' }
  end
end
