require 'spec_helper'

describe UserAuthentication do
  it { should belong_to :user }
  it { should belong_to :authentication_provider }
  it { should respond_to :uid }
  it { should respond_to :token }
end
