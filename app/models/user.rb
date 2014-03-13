class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :omniauthable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauth_providers => [:facebook]

  has_many :authentications, class_name: 'UserAuthentication'
  has_many :stations, inverse_of: :user
  has_many :notifications, inverse_of: :user

  validates_uniqueness_of :nickname
  validates_uniqueness_of :confirmation_token, allow_nil: true
  validate :valid_timezone

  # Use FriendlyId to create "pretty urls"
  extend FriendlyId
  friendly_id :nickname, :use => [:slugged]

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

  def should_generate_new_friendly_id?
    if !slug?
      nickname_changed?
    else
      false
    end
  end

  def valid_timezone
    errors.add(:timezone, "#{timezone} is not a valid zone name") unless ActiveSupport::TimeZone::MAPPING.has_key?(timezone)
  end

  def to_local_time(time)
    @_timezone = Timezone::Zone.new( zone: ActiveSupport::TimeZone::MAPPING[timezone] ) if @_timezone.nil?
    @_timezone.time(time)
  end

end
