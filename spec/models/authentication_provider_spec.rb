# == Schema Information
#
# Table name: authentication_providers
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe AuthenticationProvider do
  it { should have_many :user_authentications }
  it { should respond_to :name }
  it { should validate_uniqueness_of :name }
end
