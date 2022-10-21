class Rate < ApplicationRecord
  belongs_to :vrental
  validates :firstnight, presence: true
  validates :lastnight, presence: true
  validates :min_stay, presence: true
  validates :arrival_day, presence: true
end
