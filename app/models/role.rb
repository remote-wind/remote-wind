# This is the normalized table containing the definitions of roles and an
# association to which the role is scoped.
# @see https://github.com/RolifyCommunity/rolify
# @attr name [String]
# @attr resource_id [Integer]
# @attr resource_type [String]
# @attr created_at [DateTime]
# @attr updated_at [DateTime]
class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, join_table: :users_roles
  belongs_to :user, polymorphic: true
  scopify

  AVAILABLE_ROLES = [:admin]

  # Displays a human readable version of the role name
  # @return [String]
  def display_name
    @name.capitalize
  end
end
