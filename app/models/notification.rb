# Represents an in-app notification message.
class Notification < ActiveRecord::Base
  belongs_to :user

  scope :since, -> (time) { where("created_at >= ?", time) }

  # 8 log levels according to RFC 5424 (http://tools.ietf.org/html/rfc5424)
  LEVELS_RFC_5424 = {
      debug:  100 ,    # Detailed debug information.
      info:   200,     # Interesting events. Examples: User logs in, SQL logs.
      notice: 250,   # Normal but significant events.
      warning: 300,  # Exceptional occurrences that are not errors. Undesirable things that are not necessarily wrong.
      error:  400,    # Runtime errors that do not require immediate action but should typically be logged and monitored.
      critical: 500, # Critical conditions. Example: Application component unavailable, unexpected exception.
      alert: 550,    # Action must be taken immediately. Example: Entire website down, database unavailable, etc.
      emergency: 600 # Emergency: system is unusable.
  }

  validates_inclusion_of :level, in: LEVELS_RFC_5424.values, allow_blank: true

  # @param value integer or symbol - valid symbols are listed in LEVELS_RFC_5424
  def level= value
    if LEVELS_RFC_5424.include?(value)
      value = LEVELS_RFC_5424[value]
    end
    super(value)
  end

  # @return Symbol
  def level_to_sym
    LEVELS_RFC_5424.key(level)
  end

  # @return String
  def level_to_s
    LEVELS_RFC_5424.key(level).to_s
  end
end
