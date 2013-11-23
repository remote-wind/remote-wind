class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :omniauthable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable,
         :omniauth_providers => [:facebook]



  has_many :authentications, class_name: 'UserAuthentication'

  def self.create_from_omniauth(params)

    params = HashWithIndifferentAccess.new(params)

    attributes = {
        email: params[:info][:email],
        image: params[:info][:image],
        password: Devise.friendly_token
    }

    create(attributes)
  end

  def update_from_omniauth(params)

    params = HashWithIndifferentAccess.new(params)
    if params[:info].key?(:image)
      @image = params[:info][:image]
    end
  end
end
