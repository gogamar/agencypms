class RatePlan < ApplicationRecord
  belongs_to :company
  has_many :vrentals
  has_many :rate_periods, dependent: :destroy

  def unavailable_rate_periods
    rate_periods.pluck(:firstnight, :lastnight).map do |range|
      { from: range[0], to: range[1] }
    end
  end

  def default_start
    last_rate_period = rate_periods.find_by(lastnight: rate_periods.maximum('lastnight'))
    last_rate_period.present? ? last_rate_period.lastnight + 1.day : start
  end
end
