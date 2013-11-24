require 'spec_helper'

describe AuthenticationProvider do
  it { should have_many :user_authentications }
  it { should respond_to :name }
  it { should validate_uniqueness_of :name }
end
