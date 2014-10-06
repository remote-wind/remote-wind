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

describe AuthenticationProvider, :type => :model do
  it { is_expected.to have_many :user_authentications }
  it { is_expected.to validate_uniqueness_of :name }
end
