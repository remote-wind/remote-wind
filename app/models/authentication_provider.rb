# @todo CLEANUP - evalutate if can be removed
# @attr name [string]
# @attr created_at [datetime]
# @attr updated_at [datetime]
class AuthenticationProvider < ActiveRecord::Base
  has_many :users
  has_many :user_authentications
  validates_uniqueness_of :name
end
