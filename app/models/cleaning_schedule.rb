class CleaningSchedule < ApplicationRecord
  belongs_to :office
  belongs_to :cleaning_company
  belongs_to :vrental
  validates :cleaning_date, presence: true
  validates :cleaning_date, uniqueness: { scope: :vrental_id, message: "should be unique per vrental" }

  CLEANING_TYPES = [
    'checkout_full_cleaning',
    'checkout_laundry_pickup',
    'checkout_no_laundry',
    'checkin_full_cleaning',
    'checkin_set_laundry',
    'checkin_no_laundry',
    'dusting_needed',
    'no_cleaning'
  ]

  CLEANING_REASON = [
    'checkin',
    'checkout'
  ]
end
