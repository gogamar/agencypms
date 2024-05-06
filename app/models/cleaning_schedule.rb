class CleaningSchedule < ApplicationRecord
  belongs_to :cleaning_plan
  belongs_to :vrental
end
