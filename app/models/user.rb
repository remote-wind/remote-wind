# @attr email [String]  the default column used for database authentication
# @attr encrypted_password [String]  used by Devise
# @attr reset_password_token [String]  used by Devise
# @attr reset_password_sent_at [DateTime]  used by Devise
# @attr remember_created_at [DateTime]  used by Devise
# @attr sign_in_count [Integer]  used by Devise trackable
# @attr current_sign_in_at [DateTime]  used by Devise trackable
# @attr last_sign_in_at [DateTime]  used by Devise trackable
# @attr current_sign_in_ip [String]  used by Devise trackable
# @attr last_sign_in_ip [String]  used by Devise trackable
# @attr created_at [DateTime]
# @attr updated_at [DateTime]
# @attr image [String]  a url to an avatar - not currently in use
# @attr nickname [String]  allows users to display something else than their email
# @attr slug [String]  URL friendly version of name that can be used as a route param
# @attr timezone [String]
# @attr confirmation_token [String]  used by Devise Confirmable
# @attr confirmed_at [DateTime]  used by Devise Confirmable
# @attr confirmation_sent_at [DateTime]  used by Devise Confirmable
# @attr invitation_token [String]  used by Devise Invitable
# @attr invitation_created_at [DateTime]  used by Devise Invitable
# @attr invitation_sent_at [DateTime]   used by Devise Invitable
# @attr invitation_accepted_at [DateTime]  used by Devise Invitable
# @attr invitation_limit [Integer]  used by Devise Invitable
# @attr invited_by_id [Integer]  used by Devise Invitable
# @attr invited_by_type [String]  used by Devise Invitable
# @attr invitations_count [Integer]  used by Devise Invitable
class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :omniauthable, :database_authenticatable, :registerable,
         :confirmable, :recoverable, :rememberable, :trackable, :validatable,
         omniauth_providers: [:facebook]

  has_many :authentications, class_name: 'UserAuthentication'
  has_many :stations, inverse_of: :user
  has_many :notifications, inverse_of: :user

  validates_uniqueness_of :nickname, allow_nil: true
  validates_uniqueness_of :confirmation_token, allow_nil: true
  validate :valid_timezone

  # Use FriendlyId to create "pretty urls"
  extend FriendlyId
  friendly_id :nickname, use: [:slugged]

  # Setup default values for new records
  after_initialize do
    if self.new_record?
      self.timezone = "Stockholm"
    end
  end

  def self.create_from_omniauth(params)
    info = params[:info]

    create do |user|
        user.email    = info[:email]
        user.image    = info[:image]
        user.nickname = info[:nickname]
        user.password = Devise.friendly_token
        user.confirmed_at = Time.now
    end
  end

  def update_from_omniauth(params)
    if params[:info].key?(:image)
      @image = params[:info][:image]
    end
  end

  # @return [boolean]
  def should_generate_new_friendly_id?
    if !slug?
      nickname_changed?
    else
      false
    end
  end

  # @todo depreachiate and remove
  def valid_timezone
    unless ActiveSupport::TimeZone::MAPPING.has_key?(timezone)
      errors.add(:timezone, "#{timezone} is not a valid zone name")
    end
  end

  # @todo depreachiate and remove
  def to_local_time(time)
    Timezone['Europe/Stockholm'].time(time)
  end

end
