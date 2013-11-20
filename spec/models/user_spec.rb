require 'spec_helper'

describe User do

  it { should validate_presence_of :email }
  it { should validate_presence_of :password }
  it { should validate_uniqueness_of :email }
  it { should have_and_belong_to_many :roles }
  it { should have_many :identities }

end
