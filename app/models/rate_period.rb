class RatePeriod < ApplicationRecord
  belongs_to :rate_plan
  validates :firstnight, presence: true
  validates :lastnight, presence: true
  validates :lastnight, comparison: { greater_than: :firstnight }
  validates :firstnight, uniqueness: { scope: :rate_plan_id, message: 'Aquest periode ja existeix.' }
  validates :lastnight, uniqueness: { scope: :rate_plan_id, message: 'Aquest periode ja existeix.' }
  validates :min_stay, presence: true
  validates :arrival_day, presence: true
end
