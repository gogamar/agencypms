class CleaningSchedule < ApplicationRecord
  belongs_to :office
  belongs_to :cleaning_company
  belongs_to :vrental
  belongs_to :booking, optional: true
  belongs_to :owner_booking, optional: true
  validates :cleaning_date, presence: true
  validates :reason, presence: true
  validates :cleaning_date, uniqueness: { scope: :vrental_id, message: "should be unique per vrental" }

  CLEANING_TYPES_CHECKOUT = [
    'checkout_full_cleaning',
    'checkout_laundry_pickup',
    'checkout_no_laundry'
  ]

  CLEANING_TYPES_CHECKIN = [
    'checkin_full_cleaning',
    'checkin_set_laundry',
    'checkin_no_laundry'
  ]

  CLEANING_REASON = [
    'checkin',
    'checkout'
  ]
end
