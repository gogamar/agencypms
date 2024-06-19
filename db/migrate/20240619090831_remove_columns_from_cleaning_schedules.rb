class RemoveColumnsFromCleaningSchedules < ActiveRecord::Migration[7.0]
  def change
    remove_column :cleaning_schedules, :cleaning_start, :datetime
    remove_column :cleaning_schedules, :cleaning_end, :datetime
    remove_column :cleaning_schedules, :next_booking_date, :date
    remove_column :cleaning_schedules, :next_booking_info, :string
    remove_column :cleaning_schedules, :next_client_name, :string
    remove_column :cleaning_schedules, :locked, :boolean
    remove_column :cleaning_schedules, :full, :boolean
    remove_reference :cleaning_schedules, :booking
  end
end
