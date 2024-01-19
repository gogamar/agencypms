class Availability < ApplicationRecord
  belongs_to :vrental
  validates :date, presence: true
  validates :inventory, presence: true
  # validates :multiplier, numericality: { greater_than_or_equal_to: 0 }

  OVERRIDE = { 0 => "none", 1 => "blackout", 2 => "no_checkin", 3 => "no_checkout", 4 => "no_checkin_out" }.freeze

  def availability_rate
    @availability_rate ||= vrental.rates.find_by("firstnight <= ? AND lastnight > ?", date, date)
  end

  def rate_override
    return 0 if availability_rate.nil? || availability_rate.arrival_day == date.wday
    return 4 if availability_rate.arrival_day != date.wday
    return 2 if availability_rate.arrival_day == 7 && vrental.no_check_in == date.wday
  end

  def rate_min_stay
    return 0 if availability_rate.nil?

    availability_rate.min_stay
  end
end
