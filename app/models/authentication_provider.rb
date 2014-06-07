# == Schema Information
#
# Table name: authentication_providers
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#
class AuthenticationProvider < ActiveRecord::Base
  has_many :users
  has_many :user_authentications
  validates_uniqueness_of :name
end
