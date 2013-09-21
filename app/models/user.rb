class User < ActiveRecord::Base
  has_and_belongs_to_many :roles
  
  has_many :stations
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :stations, :email, :password, :password_confirmation, :remember_me

  def role?(role)
      return !!self.roles.find_by_name(role.to_s.camelize)
  end
  
  # block invited to to change password without accepting invitation
  # https://github.com/scambra/devise_invitable/wiki/Disabling-devise-recoverable,-if-invitation-was-not-accepted
  def send_reset_password_instructions
    super if invitation_token.nil?
  end
end
