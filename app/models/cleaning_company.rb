class CleaningCompany < ApplicationRecord
  belongs_to :office
  has_many :cleaning_schedules, dependent: :nullify

  # Assuming each cleaning company has a defined number of staff and working hours per day
  def available_hours_for_period(start_date, end_date)
    total_available_hours = 0

    (start_date.to_date..end_date.to_date).each do |date|
      total_working_hours_per_day = number_of_cleaners * max_working_hours_per_day
      allocated_hours = cleaning_schedules.where('DATE(cleaning_start) = ?', date).sum('EXTRACT(EPOCH FROM (cleaning_end - cleaning_start)) / 3600')

      total_available_hours += (total_working_hours_per_day - allocated_hours)
    end

    total_available_hours
  end

  def update_priority(cleaning_date)
    cleaning_schedules.where(cleaning_date: cleaning_date).order(:priority).each_with_index do |schedule, index|
      schedule.update(priority: index + 1)
    end
  end

  private
  def max_working_hours_per_day
    8 # for example, 8 hours per day
  end
end
