class Rate < ApplicationRecord
  belongs_to :vrental
  validates :firstnight, presence: true
  validates :lastnight, presence: true
  validates :lastnight, comparison: { greater_than: :firstnight }
  validates :firstnight, uniqueness: { scope: :vrental_id }
  validates :lastnight, uniqueness: { scope: :vrental_id }
  validates :min_stay, presence: true
  validates :arrival_day, presence: true
  validates :priceweek, presence: true
end
