require 'spec_helper'

describe User do

  subject { build_stubbed(:user) }

  it { should respond_to :nickname }
  it { should validate_presence_of :email }
  it { should validate_presence_of :password }
  it { should validate_uniqueness_of :email }

  it { should respond_to :image }
  it { should validate_uniqueness_of :nickname }


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