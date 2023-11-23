class Availability < ApplicationRecord
  belongs_to :vrental
  validates :date, presence: true
  validates :inventory, presence: true
  validates :multiplier, numericality: { greater_than_or_equal_to: 0 }

  OVERRIDE = { 0 => "none", 1 => "blackout", 2 => "no_checkin", 3 => "no_checkout", 4 => "no_checkin_out" }.freeze
end
