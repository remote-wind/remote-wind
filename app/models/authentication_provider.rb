class AuthenticationProvider < ActiveRecord::Base
  has_many :users
  has_many :user_authentications
  validates_uniqueness_of :name
end
