class CleaningSchedule < ApplicationRecord
  belongs_to :cleaning_company
  belongs_to :vrental
end
