class CleaningSchedule < ApplicationRecord
  belongs_to :office
  belongs_to :cleaning_company
  belongs_to :booking

  def update_priority
    CleaningSchedule.where(cleaning_date: cleaning_date).order(:priority).each_with_index do |schedule, index|
      schedule.update(priority: index + 1)
    end
  end
end
