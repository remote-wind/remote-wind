module Timezoned
  extend ActiveSupport::Concern

  included do
    validate :valid_timezone
  end

  # @return [Time]
  def time_to_local(time)
    time.in_time_zone(timezone || Rails.application.config.time_zone)
  end

  # @return [Time]
  def created_at_local
    time_to_local(created_at) if created_at.present?
  end

  # @return [Time]
  def updated_at_local
    time_to_local(updated_at) if updated_at.present?
  end

  private

  def valid_timezone
    unless ActiveSupport::TimeZone::MAPPING.values.include?(self.timezone)
      errors.add(:timezone, 'is not a valid time zone')
    end
  end
end
