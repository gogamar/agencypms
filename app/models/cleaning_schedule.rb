class CleaningSchedule < ApplicationRecord
  belongs_to :office
  belongs_to :cleaning_company
  belongs_to :vrental
  belongs_to :booking, optional: true
  belongs_to :owner_booking, optional: true
  validates :cleaning_date, uniqueness: { scope: :vrental_id, message: "should be unique per vrental" }

  CLEANING_TYPES = [
    'first_cleaning',
    'full_cleaning',
    'laundry_pickup',
    'cleaning_no_laundry',
    'laundry_set',
    'last_cleaning'
  ]
end
