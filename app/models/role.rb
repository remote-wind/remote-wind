class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :user, :polymorphic => true
  scopify

  def display_name
    @name.capitalize
  end
  
end
