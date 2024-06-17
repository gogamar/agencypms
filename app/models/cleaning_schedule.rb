class CleaningSchedule < ApplicationRecord
  belongs_to :office
  belongs_to :cleaning_company
  belongs_to :booking
end
