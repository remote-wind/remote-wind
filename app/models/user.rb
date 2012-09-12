class User < ActiveRecord::Base
  has_and_belongs_to_many :roles
  
  has_many :stations
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  
  def role?(role)
      return !!self.roles.find_by_name(role.to_s.camelize)
  end
end
