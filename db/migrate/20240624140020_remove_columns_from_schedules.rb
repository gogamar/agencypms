class RemoveColumnsFromSchedules < ActiveRecord::Migration[7.0]
  def change
    remove_column :cleaning_schedules, :reason
    remove_reference :cleaning_schedules, :booking
    remove_reference :cleaning_schedules, :owner_booking
  end
end
