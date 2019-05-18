
require 'rails_helper'

RSpec.describe User, type: :model do

  subject { build_stubbed(:user) }

  describe "attributes" do
    it { should respond_to :nickname }
    it { should respond_to :image }
    it { should respond_to :confirmed_at }
    it { should respond_to :confirmation_sent_at }
  end

  describe "validations" do
    subject { User.create }
    it { should validate_presence_of :email }
    it { should validate_presence_of :password }
    it { should validate_uniqueness_of :nickname }
    it { should validate_uniqueness_of :confirmation_token }
  end

  describe "relations" do
    it { should have_and_belong_to_many :roles }
    it { should have_many :notifications }
  end
end
