class AddReasonToCleaningSchedules < ActiveRecord::Migration[7.0]
  def change
    add_column :cleaning_schedules, :reason, :string
  end
end
