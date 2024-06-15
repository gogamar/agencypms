class AddColumnsToCleaningSchedules < ActiveRecord::Migration[7.0]
  def change
    add_column :cleaning_schedules, :notes, :string
    add_column :cleaning_schedules, :next_client_name, :string
  end
end
