class AddOfficeToCleaningSchedules < ActiveRecord::Migration[7.0]
  def change
    add_reference :cleaning_schedules, :office, foreign_key: true
  end
end
