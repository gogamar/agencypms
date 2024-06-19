class AddCleaningTypeToCleaningSchedules < ActiveRecord::Migration[7.0]
  def change
    add_column :cleaning_schedules, :cleaning_type, :string
    add_reference :cleaning_schedules, :booking, foreign_key: true
    add_reference :cleaning_schedules, :owner_booking, foreign_key: true
  end
end
