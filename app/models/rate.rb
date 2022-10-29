class Rate < ApplicationRecord
  belongs_to :vrental
  validates :firstnight, presence: true
  validates :lastnight, presence: true
  validates :lastnight, comparison: { greater_than: :firstnight }
  validates :firstnight, uniqueness: { scope: :vrental_id }
  validates :lastnight, uniqueness: { scope: :vrental_id }
  validates :min_stay, presence: true
  validates :arrival_day, presence: true
  scope :up_comings, ->(nb_days) {
    where('firstnight >= ? AND firstnight < ?',
          Time.zone.now,
          Time.zone.now + nb_days.days).order(firstnight: :asc)
  }

end
