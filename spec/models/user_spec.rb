require 'spec_helper'

describe User do

  it { should respond_to :nickname }
  it { should validate_presence_of :email }
  it { should validate_presence_of :password }
  it { should validate_uniqueness_of :email }
  it { should have_and_belong_to_many :roles }
  it { should have_many :authentications }
  it { should respond_to :image }

  describe ".create_from_omniauth" do

    subject { User.create_from_omniauth(OmniAuth::MockFactory.facebook)  }

    its(:email) { should eq 'joe@bloggs.com' }
    its(:nickname) { should eq 'jbloggs' }
    its(:image) { should eq 'http://graph.facebook.com/1234567/picture?type=square' }

  end

end
