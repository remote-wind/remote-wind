# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default("")
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  image                  :string(255)
#  nickname               :string(255)
#  slug                   :string(255)
#  timezone               :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  invitation_token       :string(255)
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string(255)
#  invitations_count      :integer          default(0)
#

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

  def valid_timezone
    errors.add(:timezone, "#{timezone} is not a valid zone name") unless ActiveSupport::TimeZone::MAPPING.has_key?(timezone)
  end

  def to_local_time(time)
    @_timezone = Timezone::Zone.new( zone: ActiveSupport::TimeZone::MAPPING[timezone] ) if @_timezone.nil?
    @_timezone.time(time)
  end

end
